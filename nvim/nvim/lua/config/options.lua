-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General options
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
-- over ssh: clipboard via OSC 52 escape codes through the terminal (kitty
-- clipboard_control allows it) instead of X forwarding / remote xclip
if vim.env.SSH_TTY then
    vim.g.clipboard = "osc52"
end
vim.opt.spell = false

-- Window options
vim.wo.number = true
vim.wo.cursorline = true

-- Global options
vim.o.updatetime = 300
vim.o.timeoutlen = 300

-- Plugin specific options
vim.g.better_whitespace_operator = ""
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0