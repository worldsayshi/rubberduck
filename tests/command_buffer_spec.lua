describe("stream_command_to_floating_buffer", function()
	local trim_table = require("trim_table")
	local M = require("command_buffer")
	-- local helpers = require('plenary.test_harness.helpers')
	local eq = assert.are.same

	local function execute_command_and_get_buffer_lines(cmd)
		local command_finished = false

		M.stream_command_to_floating_buffer(cmd, function()
			command_finished = true
		end)
		vim.wait(5000, function()
			return command_finished
		end)
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		return trim_table(lines)
	end

	it("streams the output of a command to a buffer", function()
		-- Define the command to be executed
		local cmd = { "echo", "-n", "Hello, World!" }
		local buf_lines = execute_command_and_get_buffer_lines(cmd)

		-- Check if the buffer contains the expected output
		eq({ "Hello, World!" }, buf_lines)
	end)

	it("correctly renders command output with newline as two lines in the buffer", function()
		local cmd = { "printf", "Line 1\nLine 2" }
		local buf_lines = execute_command_and_get_buffer_lines(cmd)

		eq({ "Line 1", "Line 2" }, buf_lines)
	end)
end)
