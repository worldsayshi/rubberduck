describe("stream_command_to_floating_buffer", function()
	local M = require("command_buffer")
	-- local helpers = require('plenary.test_harness.helpers')
	local eq = assert.are.same

	local function trim_table(t)
		local start, finish = 1, #t
		while start <= #t and t[start] == "" do
			start = start + 1
		end
		while finish > start and t[finish] == "" do
			finish = finish - 1
		end
		return vim.list_slice(t, start, finish)
	end

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
		-- Define the command to be executed with output containing a newline
		local cmd = { "printf", "Line 1\nLine 2" }
		local buf_lines = execute_command_and_get_buffer_lines(cmd)

		-- Check if the buffer contains the expected output as two separate lines
		-- eq("Line 1", buf_lines[#buf_lines])
		-- lua index actually starts at 1, not 0!
		-- eq("Line 2", buf_lines[#buf_lines + 1])
		eq({ "Line 1", "Line 2" }, buf_lines)
	end)
end)

