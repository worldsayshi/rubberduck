print("very top ot the test file")
print("beginning of test file")

describe("stream_command_to_floating_buffer", function()
	local M = require("buffer")
	-- local helpers = require('plenary.test_harness.helpers')
	local eq = assert.are.same
	it("streams the output of a command to a buffer", function()
		print("starting the test")
		-- Create a new buffer to simulate the original buffer
		-- local original_bufnr = vim.api.nvim_create_buf(false, true)

		-- Define the command to be executed
		local cmd = { "echo", "Hello, World!" }

		print("starting the function")
		-- Call the function
		M.stream_command_to_floating_buffer(cmd, nil)

		print("starting the wait")
		-- Wait for the command to complete
		vim.wait(100, function()
			return vim.fn.jobwait({ vim.fn.jobstart(cmd) }, 0)[1] ~= -1
		end)

		-- Get the contents of the floating buffer
		local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

		-- Check if the buffer contains the expected output
		eq("Hello, World!", buf_lines[#buf_lines])
	end)
end)
