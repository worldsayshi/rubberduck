local M = {}

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
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })

	-- Set text width for the buffer
	local text_width = width - 4 -- Subtract 4 to account for padding
	vim.api.nvim_set_option_value("wrap", true, { win = win })
	vim.api.nvim_set_option_value("linebreak", true, { win = win })
	vim.api.nvim_set_option_value("breakindent", true, { win = win })
	vim.api.nvim_set_option_value("textwidth", text_width, { buf = buf })

	-- Function to append lines to the buffer and scroll
	local function append_line(_, data)
		if data then
			vim.schedule(function()
				vim.api.nvim_buf_set_option(buf, "modifiable", true)
				for _, line in ipairs(data) do
					local wrapped_lines = {}
					for i = 1, #line, text_width do
						table.insert(wrapped_lines, line:sub(i, i + text_width - 1))
					end
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, wrapped_lines)
				end
				vim.api.nvim_buf_set_option(buf, "modifiable", false)

				-- Scroll to the bottom of the buffer
				local line_count = vim.api.nvim_buf_line_count(buf)
				vim.api.nvim_win_set_cursor(win, { line_count, 0 })
			end)
		end
	end

	-- Execute the command and stream output to the buffer
	vim.fn.jobstart(cmd, {
		on_stdout = append_line,
		on_stderr = append_line,
		on_exit = function(_, exit_code)
			vim.schedule(function()
				vim.api.nvim_buf_set_option(buf, "modifiable", true)
				if exit_code ~= 0 then
					vim.api.nvim_buf_set_lines(
						buf,
						-1,
						-1,
						false,
						{ "", "Error: Command exited with code " .. exit_code }
					)
				else
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "Refactoring completed successfully." })
				end
				vim.api.nvim_buf_set_option(buf, "modifiable", false)

				-- Scroll to the bottom of the buffer
				local line_count = vim.api.nvim_buf_line_count(buf)
				vim.api.nvim_win_set_cursor(win, { line_count, 0 })

				-- Reload the original buffer
				vim.api.nvim_buf_call(original_bufnr, function()
					vim.cmd("edit!")
				end)

				-- Set up autocmd to close the floating window when cursor moves
				vim.api.nvim_create_autocmd("CursorMoved", {
					buffer = buf,
					callback = function()
						vim.api.nvim_win_close(win, true)
					end,
					once = true,
				})
			end)
		end,
	})

	-- Set up a keymap to close the floating window
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
end

return M