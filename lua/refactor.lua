local M = {}

-- Refactors the file using AI
M.Refactor_file = function()
	local current_file = vim.fn.expand("%:p")

	-- Prompt user for input
	local user_text = vim.fn.input("Refactor " .. vim.fs.basename(current_file))
	if user_text == "" then
		vim.notify("Refactoring aborted", vim.log.levels.INFO)
		return
	end

	-- Save the file before refactoring
	vim.cmd("write")

	local cmd
	local file_extension = vim.fn.expand("%:e")

	if file_extension == "kind2" then
		cmd = string.format('kindcoder "%s" "%s"', current_file, user_text)
	elseif file_extension == "ts" then
		cmd = string.format('tscoder "%s" "%s"', current_file, user_text)
	else
		cmd = string.format('refactor "%s" "%s"', current_file, user_text)
	end

	-- Add --check flag if user_text starts with '-' or is empty
	if user_text:match("^%-") or user_text == "" then
		cmd = cmd .. " --check"
	end

	-- Store the current buffer number
	local original_bufnr = vim.api.nvim_get_current_buf()

	require("command_buffer").stream_command_to_floating_buffer(cmd, function()
		-- Reload the original buffer
		vim.api.nvim_buf_call(original_bufnr, function()
			vim.cmd("edit!")
		end)
	end)
end

return M
