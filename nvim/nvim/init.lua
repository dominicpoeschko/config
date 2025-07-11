vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.clipboard = "unnamedplus"
vim.wo.number = true
vim.wo.cursorline = true
vim.o.updatetime = 300
vim.o.timeoutlen = 300

vim.cmd('let g:better_whitespace_operator=""')

vim.cmd('set ts=4')
vim.cmd('set sw=4')
vim.cmd('set expandtab')
vim.cmd('set nospell')

require("config.lazy")

vim.keymap.set("n", "<leader>r", ":%s///gc<Left><Left><Left><Left>", {desc = "Search and Replace", silent = false})
vim.keymap.set("n", "<leader>f", ':Telescope smart_open<CR>', {noremap = true, silent = true })
vim.keymap.set("n", "<leader>d", ':Telescope find_files follow=true<CR>', {noremap = true, silent = true })
vim.keymap.set("n", "<leader>x", ':Telescope live_grep<CR>', {noremap = true, silent = true })
vim.keymap.set("n", "<leader>s", ':Telescope grep_string<CR>', {noremap = true, silent = true })

vim.keymap.set("n", "<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {desc = "Go to Definition"})
vim.keymap.set("n", "<leader>gc", "<cmd>lua vim.lsp.buf.declaration()<CR>", {desc = "Go to Declaration"})
vim.keymap.set("n", "<leader>lf", "<cmd>lua if vim.bo.filetype == 'cpp' or vim.bo.filetype == 'c' then vim.cmd('ClangFormat') else vim.lsp.buf.format() end<cr>", {desc = "Format"})
vim.keymap.set("n", "<leader>li", "<cmd>lua vim.lsp.buf.hover()<cr>", {desc = "Hover Info"})
vim.keymap.set("n", '<leader>ld', '<cmd>lua vim.diagnostic.open_float({scope="line"})<CR>', {desc = "Line diagnostic", noremap=true, silent=true})

vim.keymap.set('n', '<F5>', require('dap').continue)
vim.keymap.set('n', '<F10>', require('dap').step_over)
vim.keymap.set('n', '<F11>', require('dap').step_into)
vim.keymap.set('n', '<F12>', require('dap').step_out)

vim.keymap.set('n', '<leader>wb', require('dap').toggle_breakpoint)
vim.keymap.set('n', '<leader>wu', require('dapui').toggle)

require("which-key").add({"<leader>l", group = "+LSP"})
require("which-key").add({"<leader>g", group = "+Goto"})
require("which-key").add({"<leader>w", group = "+Debug"})

vim.cmd('colorscheme gruvbox')

vim.cmd([[command Q q]])
vim.cmd([[command WQ wq]])
vim.cmd([[command W w]])
vim.cmd([[command Wq wq]])
vim.cmd([[command Wa wa]])
vim.cmd([[command WA wa]])
