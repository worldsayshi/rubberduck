local group = vim.api.nvim_create_augroup("rubberduck", {})

local function au(event, callback)
	vim.api.nvim_create_autocmd(event, { group = group, callback = callback })
end

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
-- au("InsertEnter", rubberduck.onInsertEnter)
vim.api.nvim_set_keymap(
	"n",
	"<leader>r",
	-- ":lua require('rubberduck').Refactor_file()<CR>",
	":RBRefactor<cr>",
	-- vim.cmd.RBRefactor,
	{ noremap = true, silent = false }
)
