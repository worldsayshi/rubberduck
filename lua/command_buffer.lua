local buffer = require("buffer")

local M = {}

M.stream_command_to_floating_buffer = function(cmd, command_finished_callback)
	local _, append_text = buffer.create_floating_buffer()
	vim.fn.jobstart(cmd, {
		on_stdout = function(_, data)
			append_text(data)
		end,
		on_stderr = function(_, data)
			append_text(data)
		end,
		on_exit = function(_, exit_code)
			if exit_code ~= 0 then
				append_text({ "", "Error: Command exited with code " .. exit_code })
			end
			if command_finished_callback then
				command_finished_callback()
			end
		end,
	})
end

return M
