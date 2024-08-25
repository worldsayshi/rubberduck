local buffer = require("buffer")
local eq = assert.are.same

describe("buffer", function()
	it("should add what is appended", function()
		local append_text = buffer.create_floating_buffer()
		append_text({ "" })
		local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		eq(buf_lines, { "" })
	end)
end)
