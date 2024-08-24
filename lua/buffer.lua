M = {}

M.stream_command_to_floating_buffer = function(cmd, command_finished_callback)
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
	vim.api.nvim_set_option_value("wrap", true, { win = win })
	vim.api.nvim_set_option_value("linebreak", true, { win = win })
	vim.api.nvim_set_option_value("breakindent", true, { win = win })
	-- Function to append text to the buffer and scroll
	local function append_text(_, data)
		if data then
			vim.schedule(function()
				vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
				local last_line = vim.api.nvim_buf_get_lines(buf, -2, -1, false)[1] or ""
				for _, line in ipairs(data) do
					if line:sub(-1) == "\n" then
						vim.api.nvim_buf_set_lines(buf, -2, -1, false, { last_line .. line:sub(1, -2) })
						last_line = ""
					else
						last_line = last_line .. line
					end
				end
				if last_line ~= "" then
					vim.api.nvim_buf_set_lines(buf, -2, -1, false, { last_line })
				end
				vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

				-- Scroll to the bottom of the buffer
				local line_count = vim.api.nvim_buf_line_count(buf)
				vim.api.nvim_win_set_cursor(win, { line_count, 0 })
			end)
		end
	end
	-- Execute the command and stream output to the buffer
	vim.fn.jobstart(cmd, {
		on_stdout = append_text,
		on_stderr = append_text,
		on_exit = function(_, exit_code)
			vim.schedule(function()
				vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
				if exit_code ~= 0 then
					vim.api.nvim_buf_set_lines(
						buf,
						-1,
						-1,
						false,
						{ "", "Error: Command exited with code " .. exit_code }
					)
				end
				vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

				-- Scroll to the bottom of the buffer
				local line_count = vim.api.nvim_buf_line_count(buf)
				vim.api.nvim_win_set_cursor(win, { line_count, 0 })

				if command_finished_callback then
					command_finished_callback()
				end

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
