local M = {}

M.create_floating_buffer = function()
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

	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("wrap", true, { win = win })
	vim.api.nvim_set_option_value("linebreak", true, { win = win })
	vim.api.nvim_set_option_value("breakindent", true, { win = win })

	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })

	local function append_text(data, callback)
		if data then
			vim.schedule(function()
				vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
				local last_line = vim.api.nvim_buf_line_count(buf)
				local last_line_content = vim.api.nvim_buf_get_lines(buf, last_line - 1, last_line, false)[1]

				-- Append the first chunk to the last line of the buffer
				vim.api.nvim_buf_set_lines(buf, last_line - 1, last_line, false, { last_line_content .. data[1] })

				-- Append the rest of the data as new lines
				if #data > 1 then
					vim.api.nvim_buf_set_lines(buf, last_line, -1, false, { unpack(data, 2) })
				end
				--vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
				vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

				local line_count = vim.api.nvim_buf_line_count(buf)
				vim.api.nvim_win_set_cursor(win, { line_count, 0 })
				if callback then
					callback()
				end
			end)
		end
	end

	return buf, append_text
end

return M
