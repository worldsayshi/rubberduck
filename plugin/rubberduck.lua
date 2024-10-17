---@module 'rubberduck'
local rubberduck = setmetatable({}, {
	__index = function(_, name)
		return function()
			require("rubberduck")[name]()
		end
	end,
})

vim.api.nvim_create_user_command("RBRefactor", function()
	rubberduck.Refactor_file()
end, {})

vim.api.nvim_create_user_command("RBdo", function()
	rubberduck.do_async_stuff()
end, {})
