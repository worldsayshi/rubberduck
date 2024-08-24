describe("stream_command_to_floating_buffer", function()
	local M = require("buffer")
	-- local helpers = require('plenary.test_harness.helpers')
	local eq = assert.are.same
	it("streams the output of a command to a buffer", function()
		local command_finished = false

		-- Define the command to be executed
		local cmd = { "echo", "Hello, World!" }
		M.stream_command_to_floating_buffer(cmd, function()
			command_finished = true
		end)
		vim.wait(5000, function()
			return command_finished
		end)
		-- Get the contents of the floating buffer
		local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

		-- Check if the buffer contains the expected output
		eq("Hello, World!", buf_lines[#buf_lines])
	end)
end)
