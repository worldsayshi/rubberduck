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

	local function append_text(data)
		if data then
			vim.schedule(function()
				vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
				vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

				local line_count = vim.api.nvim_buf_line_count(buf)
				vim.api.nvim_win_set_cursor(win, { line_count, 0 })
			end)
		end
	end

	return append_text
end

return M
