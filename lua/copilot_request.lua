local curl = require("plenary.curl")

local random = math.random

-- math.randomseed(os.time())

local M = {}

local function uuid()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
		return string.format("%x", v)
	end)
end

M.make_copilot_request = function(token, prompt) --, mock_machine_id, mock_session_id, mock_request_id)
	local mock_machine_id = uuid()
	local mock_session_id = uuid()
	local mock_request_id = uuid()

	local headers = {
		["authorization"] = "Bearer " .. token,
		["content-type"] = "application/json",
		["copilot-integration-id"] = "vscode-chat",
		["editor-plugin-version"] = "CopilotChat.nvim/2.0.0",
		["editor-version"] = "Neovim/0.10.0",
		["openai-intent"] = "conversation-panel",
		["openai-organization"] = "github-copilot",
		["user-agent"] = "CopilotChat.nvim/2.0.1",
		["vscode-machineid"] = mock_machine_id,
		["vscode-sessionid"] = mock_session_id,
		["x-request-id"] = mock_request_id,
	}

	local body = vim.json.encode({
		nwo = "github/copilot.vim",
		messages = {
			{
				role = "system",
				content = "You are a helpful programming chatbot.",
			},
			{
				role = "user",
				content = prompt,
			},
		},
	})

	local response = curl.post("https://api.githubcopilot.com/chat/completions", {
		headers = headers,
		body = body,
	})

	if response.status ~= 200 then
		error("HTTP request failed: " .. response.status)
	end

	return response.body
end

-- Usage example:
-- local response = make_copilot_request(token, prompt, mock_machine_id, mock_session_id, mock_request_id)
-- print(response)
--

M.get_copilot_token = function()
	local access_token = vim.fn.readfile(".copilot_token")[1]

	local response = curl.get("https://api.github.com/copilot_internal/v2/token", {
		headers = {
			["authorization"] = "token " .. access_token,
			["editor-version"] = "Neovim/0.10.0",
			["editor-plugin-version"] = "copilot.vim/1.16.0",
			["user-agent"] = "GithubCopilot/1.155.0",
		},
	})

	if response.status ~= 200 then
		error("Failed to get Copilot token: " .. response.status)
	end

	local resp_json = vim.json.decode(response.body)
	return resp_json.token
end

M.get_device_code = function()
	local response = curl.post("https://github.com/login/device/code", {
		headers = {
			["accept"] = "application/json",
			["editor-version"] = "Neovim/0.10.0",
			["editor-plugin-version"] = "copilot.vim/1.16.0",
			["content-type"] = "application/json",
			["user-agent"] = "GithubCopilot/1.155.0",
			["accept-encoding"] = "gzip,deflate,br",
		},
		body = vim.json.encode({
			client_id = "Iv1.b507a08c87ecfe98",
			scope = "read:user",
		}),
	})

	if response.status ~= 200 then
		error("Failed to get device code: " .. response.status)
	end

	return vim.json.decode(response.body)
end

M.get_access_token = function(device_code)
	local response = curl.post("https://github.com/login/oauth/access_token", {
		headers = {
			["accept"] = "application/json",
			["editor-version"] = "Neovim/0.10.0",
			["editor-plugin-version"] = "copilot.vim/1.16.0",
			["content-type"] = "application/json",
			["user-agent"] = "GithubCopilot/1.155.0",
			["accept-encoding"] = "gzip,deflate,br",
		},
		body = vim.json.encode({
			client_id = "Iv1.b507a08c87ecfe98",
			device_code = device_code,
			grant_type = "urn:ietf:params:oauth:grant-type:device_code",
		}),
	})

	if response.status ~= 200 then
		error("Failed to get access token: " .. response.status)
	end

	local resp_json = vim.json.decode(response.body)
	local access_token = resp_json.access_token

	if access_token then
		local file = io.open(".copilot_token", "w")
		file:write(access_token)
		file:close()
		print("Authentication success!")
	end

	return access_token
end

M.login = function()
	local device_code_response = M.get_device_code()
	print(
		"Please visit "
			.. device_code_response.verification_uri
			.. " and enter the code: "
			.. device_code_response.user_code
	)

	local access_token = nil
	while not access_token do
		-- local char = vim.fn.getchar(0)
		local char = vim.fn.getchar()
		if char == 27 or char == 113 or char == 3 then
			error("Login process aborted by user.")
		end

		-- vim.wait(5000, function()
		--     local char = vim.fn.getchar(0)
		-- 	if char == 27 or char == 113 or char == 3 then
		-- 		error("Login process aborted by user.")
		-- 	end
		-- end)
		local status, result = pcall(M.get_access_token, device_code_response.device_code)
		if status then
			access_token = result
		else
			print("Waiting for user to complete authentication...")
		end
	end

	print("Login successful! Token stored.")
end

return M
