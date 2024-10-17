local M = {}

local a = require("plenary.async")

-- local function _internal_do_async_stuff()
-- 	local tx, rx = a.control.channel.oneshot()
-- 	print("hello")
-- 	a.run(function()
-- 		-- sleep for a bit
-- 		-- vim.wait(2000)
-- 		local ret = long_running_fn()
-- 		tx(ret)
-- 	end)
--
-- 	local ret2 = rx()
-- 	print("ret: ", ret2)
-- end

local function long_running_fn()
	local sum = 0
	for i = 1, 1000000 do
		sum = sum + i
	end
	return sum
end

local sender, receiver = a.control.channel.mpsc()

local function _event_listener()
	local char = vim.fn.getchar()
	print("char: ", char)
	if char == 27 or char == 113 or char == 3 then
		-- error("Login process aborted by user.")
		sender.send({ abort = true })
	end
end

local function _long_runner()
	local value = long_running_fn()
	sender.send({ value = value })
end

M.do_async_stuff = function()
	-- https://github.com/nvim-lua/plenary.nvim/issues/252#issuecomment-989592726
	-- a.run(_internal_do_async_stuff)
	a.run(_event_listener)
	a.run(_long_runner)

	a.run(function()
		local result = receiver.recv()
		if result.abort then
			print("Aborted!")
		else
			print("Result: ", result.value)
		end
	end)
end

return M
