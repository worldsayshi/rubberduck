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
	while true do
		print("Listening for events")
		vim.wait(1000)
		if vim.fn.getchar(1) ~= 0 then
			local char = vim.fn.getchar()

			print("char: ", char)
			if char == 27 or char == 113 or char == 3 then
				-- error("Login process aborted by user.")
				sender.send({ abort = true })
			end
		end
	end
end

local function _long_runner()
	local value = long_running_fn()
	sender.send({ value = value })
end

local function _send_abort_signal()
	-- vim.wait(1000)
	sender.send({ abort = true })
end

M.do_async_stuff2 = function()
	-- https://github.com/nvim-lua/plenary.nvim/issues/252#issuecomment-989592726
	-- a.run(_internal_do_async_stuff)
	-- a.run(_long_runner)

	-- a.run(function()
	-- 	a.run(_event_listener)
	-- 	a.run(function()
	-- 		local result = receiver.recv()
	-- 		if result.abort then
	-- 			print("Aborted!")
	-- 		else
	-- 			print("Result: ", result.value)
	-- 		end
	-- 	end)
	-- 	-- a.run(_send_abort_signal)
	-- end)
	local function coroutine1()
		print("Coroutine 1 start")
		vim.schedule(function()
			print("Coroutine 1 after pause")
		end)
	end

	local function coroutine2()
		print("Coroutine 2 start")
		vim.schedule(function()
			print("Coroutine 2 after pause")
		end)
	end

	coroutine1()
	coroutine2()
end

M.do_async_stuff3 = function()
	local function coroutine1()
		print("Coroutine 1 start")
		coroutine.yield()
		print("Coroutine 1 after yield")
		coroutine.yield()
		print("Coroutine 1 end")
	end

	local function coroutine2()
		print("Coroutine 2 start")
		coroutine.yield()
		print("Coroutine 2 after yield")
		coroutine.yield()
		print("Coroutine 2 end")
	end

	-- Create coroutine objects
	local co1 = coroutine.create(coroutine1)
	local co2 = coroutine.create(coroutine2)

	-- Function to resume both coroutines
	local function resume_coroutines()
		if coroutine.status(co1) ~= "dead" then
			coroutine.resume(co1)
		end
		if coroutine.status(co2) ~= "dead" then
			coroutine.resume(co2)
		end
	end

	-- Run the coroutines
	resume_coroutines() -- Start both coroutines
	resume_coroutines() -- Resume after first yield
	resume_coroutines() -- Resume after second yield
	resume_coroutines() -- Finish both coroutines
end

local curl = require("plenary.curl")

M.do_async_stuff = function()
	print("hello")
	local c1 = coroutine.create(function()
		print("hi")
		local res = curl.get("http://localhost:3000")
		print("res: ", res)
	end)
	coroutine.resume(c1)
	-- local c1 = coroutine.create(function()
	-- 	print("co1 - inside")
	-- 	curl.get("http://localhost:3000", {
	-- 		callback = function(output)
	-- 			vim.print("output: ")
	-- 			vim.pretty_print(output.body)
	-- 		end,
	-- 	})
	--
	-- 	coroutine.yield()
	-- 	print("Coroutine 1 after yield")
	-- end)
	--
	-- coroutine.resume(c1)
	-- coroutine.resume(c1)
	-- print("co1")
	-- coroutine.resume(c1)
	-- vim.print("response: ", response)
end

return M
