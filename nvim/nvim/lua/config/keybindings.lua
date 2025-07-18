-- Search and Replace
vim.keymap.set("n", "<leader>r", ":%s///gc<Left><Left><Left><Left>", {desc = "Search and Replace", silent = false})

-- Telescope
vim.keymap.set("n", "<leader>f", ':Telescope smart_open<CR>', {noremap = true, silent = true})
vim.keymap.set("n", "<leader>d", ':Telescope find_files follow=true<CR>', {noremap = true, silent = true})
vim.keymap.set("n", "<leader>x", ':Telescope live_grep<CR>', {noremap = true, silent = true})
vim.keymap.set("n", "<leader>s", ':Telescope grep_string<CR>', {noremap = true, silent = true})

-- LSP
vim.keymap.set("n", "<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {desc = "Go to Definition"})
vim.keymap.set("n", "<leader>gc", "<cmd>lua vim.lsp.buf.declaration()<CR>", {desc = "Go to Declaration"})
vim.keymap.set("n", "<leader>lf", "<cmd>lua if vim.bo.filetype == 'cpp' or vim.bo.filetype == 'c' then vim.cmd('ClangFormat') else vim.lsp.buf.format() end<cr>", {desc = "Format"})
vim.keymap.set("n", "<leader>li", "<cmd>lua vim.lsp.buf.hover()<cr>", {desc = "Hover Info"})
vim.keymap.set("n", '<leader>ld', '<cmd>lua vim.diagnostic.open_float({scope="line"})<CR>', {desc = "Line diagnostic", noremap=true, silent=true})

-- DAP (Debug Adapter Protocol)
vim.keymap.set('n', '<F5>', require('dap').continue, {desc = "Debug: Start/Continue"})
vim.keymap.set('n', '<F9>', require('dap').step_out, {desc = "Debug: Step Out"})
vim.keymap.set('n', '<F10>', require('dap').step_over, {desc = "Debug: Step Over"})
vim.keymap.set('n', '<F11>', require('dap').step_into, {desc = "Debug: Step Into"})
vim.keymap.set('n', '<leader>wb', require('dap').toggle_breakpoint, {desc = "Debug: Toggle Breakpoint"})
vim.keymap.set('n', '<leader>wu', require('dapui').toggle, {desc = "Debug: Toggle UI"})

-- Which-key groups
require("which-key").add({"<leader>l", group = "+LSP"})
require("which-key").add({"<leader>g", group = "+Goto"})
require("which-key").add({"<leader>w", group = "+Debug"})
