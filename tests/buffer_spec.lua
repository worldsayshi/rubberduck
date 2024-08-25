describe("buffer", function()
	local eq = assert.are.same
	local buffer = require("buffer")
	local trim_table = require("trim_table")
	it("should add what is appended", function()
		local buf, append_text = buffer.create_floating_buffer()
		local append_finished = false
		append_text({ "hello" }, function()
			append_finished = true
		end)
		vim.wait(1000, function()
			return append_finished
		end)

		local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		eq({ "hello" }, trim_table(buf_lines))
	end)

	-- TODO I dunno how to test inserting newlines, because \n isn't the kind of newline
	-- that nvim_buf_set_line seems to like.
	it("should stitch together text starting at the end of the last input", function()
		local buf, append_text = buffer.create_floating_buffer()
		local append_finished = false
		append_text({ "hello " }, function()
			append_text({ "world" }, function()
				append_finished = true
			end)
		end)
		vim.wait(5000, function()
			return append_finished
		end)

		local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		eq({ "hello world" }, trim_table(buf_lines))
	end)
end)
