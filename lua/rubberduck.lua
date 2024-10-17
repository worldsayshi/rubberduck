local M = {}

M.Refactor_file = require("refactor").Refactor_file

M.login = require("copilot_request").login
--- 'Neovim/' .. vim.version().major .. '.' .. vim.version().minor .. '.' .. vim.version().patch

M.do_async_stuff = require("lua_test").do_async_stuff

return M
