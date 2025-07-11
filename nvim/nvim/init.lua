-- Load configuration modules
require("config.options")
require("config.lazy")
require("config.keybindings")

vim.cmd('colorscheme gruvbox')

vim.cmd([[command Q q]])
vim.cmd([[command WQ wq]])
vim.cmd([[command W w]])
vim.cmd([[command Wq wq]])
vim.cmd([[command Wa wa]])
vim.cmd([[command WA wa]])
