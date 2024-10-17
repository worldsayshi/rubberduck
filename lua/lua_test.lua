local M = {}

local function long_running_fn()
	local sum = 0
	for i = 1, 10000 do
		sum = sum + i
	end
	return sum
end

local a = require("plenary.async")

local function _internal_do_async_stuff()
	local tx, rx = a.control.channel.oneshot()
	print("hello")
	a.run(function()
		-- sleep for a bit
		-- vim.wait(2000)
		local ret = long_running_fn()
		tx(ret)
	end)

	local ret2 = rx()
	print("ret: ", ret2)
end
M.do_async_stuff = function()
	-- https://github.com/nvim-lua/plenary.nvim/issues/252#issuecomment-989592726
	a.run(_internal_do_async_stuff)
end

return M
