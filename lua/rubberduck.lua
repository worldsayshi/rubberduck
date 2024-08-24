local M = {}

M.a_function = function()
	return "Hello"
end

-- Refactors the file using AI
M.Refactor_file = function()
	local current_file = vim.fn.expand("%:p")
	vim.notify("Current file: " .. current_file, vim.log.levels.INFO)

	-- Prompt user for input
	local user_text = vim.fn.input("Enter refactor request: ")
	if user_text == "" then
		vim.notify("Refactoring aborted", vim.log.levels.INFO)
		return
	end
	vim.notify("User input: " .. user_text, vim.log.levels.INFO)

	-- Save the file before refactoring
	vim.cmd("write")

	local cmd
	local file_extension = vim.fn.expand("%:e")
	vim.notify("File extension: " .. file_extension, vim.log.levels.INFO)

	if file_extension == "kind2" then
		cmd = string.format('kindcoder "%s" "%s"', current_file, user_text)
	elseif file_extension == "ts" then
		cmd = string.format('tscoder "%s" "%s"', current_file, user_text)
	else
		cmd = string.format('refactor "%s" "%s"', current_file, user_text)
	end

	vim.notify("Command: " .. cmd, vim.log.levels.INFO)

	-- Add --check flag if user_text starts with '-' or is empty
	if user_text:match("^%-") or user_text == "" then
		cmd = cmd .. " --check"
	end

	-- Store the current buffer number
	local original_bufnr = vim.api.nvim_get_current_buf()

	require("buffer").stream_command_to_floating_buffer(cmd, function()
		-- Reload the original buffer
		vim.api.nvim_buf_call(original_bufnr, function()
			vim.cmd("edit!")
		end)
	end)
end

return M
