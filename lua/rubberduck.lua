local M = {}

-- Refactors the file using AI
M.Refactor_file = function()
	local current_file = vim.fn.expand("%:p")
	vim.notify("Current file: " .. current_file, vim.log.levels.INFO)

	-- Prompt user for input
	local user_text = vim.fn.input("Enter refactor request: ")
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

	-- Create a floating window with a new buffer
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
	})

	-- Set buffer options
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })

	-- Function to append lines to the buffer
	local function append_line(_, data)
		if data then
			vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
			vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
		end
	end

	-- Execute the command and stream output to the buffer
	vim.fn.jobstart(cmd, {
		on_stdout = append_line,
		on_stderr = append_line,
		on_exit = function(_, exit_code)
			vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
			if exit_code ~= 0 then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "Error: Command exited with code " .. exit_code })
			else
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "Refactoring completed successfully." })
			end
			vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

			-- Reload the current file
			vim.cmd("edit!")

			-- Set up autocmd to close the floating window when cursor moves
			vim.api.nvim_create_autocmd("CursorMoved", {
				buffer = buf,
				callback = function()
					vim.api.nvim_win_close(win, true)
				end,
				once = true,
			})
		end,
	})

	-- Set up a keymap to close the floating window
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
end

-- Set up the key mapping
-- vim.api.nvim_set_keymap("n", "<leader>r", ":lua Refactor_file()<CR>", { noremap = true, silent = true })

return M
