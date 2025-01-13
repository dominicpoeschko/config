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

vim.keymap.set({"n", "v"}, "<leader>r", ":%s///gc<Left><Left><Left><Left>", {desc = "Search and Replace", silent = false})
vim.keymap.set("n", "<leader>f", ':Telescope smart_open<CR>', {noremap = true, silent = true })

vim.keymap.set("n", "<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {desc = "Go to Definition"})
vim.keymap.set("n", "<leader>gc", "<cmd>lua vim.lsp.buf.declaration()<CR>", {desc = "Go to Declaration"})
vim.keymap.set("n", "<leader>lf", "<cmd>lua if vim.bo.filetype == 'cpp' or vim.bo.filetype == 'c' then vim.cmd('ClangFormat') else vim.lsp.buf.format() end<cr>", {desc = "Format"})
vim.keymap.set("n", "<leader>li", "<cmd>lua vim.lsp.buf.hover()<cr>", {desc = "Hover Info"})
vim.keymap.set("n", '<leader>ld', '<cmd>lua vim.diagnostic.open_float({scope="line"})<CR>', {desc = "Line diagnostic", noremap=true, silent=true})

require("which-key").add({"<leader>l", group = "+LSP"})
require("which-key").add({"<leader>g", group = "+Goto"})

--function lsp_config.tsserver_on_attach(client, bufnr)
--    lsp_config.common_on_attach(client, bufnr)
--    client.resolved_capabilities.document_formatting = true
--end

local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
}
local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
    vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
    vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
    vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
end)

vim.g.rainbow_delimiters = { highlight = highlight }
require("ibl").setup { scope = { highlight = highlight } }

hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

require("lspconfig").clangd.setup {
    cmd = {
        "clangd",
        "--header-insertion=never",
        "--compile-commands-dir=build",
        "--all-scopes-completion",
        "--background-index",
        "--enable-config"
    },
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    on_attach = function(client, bufnr)
    end,
    handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            virtual_text = false,
            signs = true,
            underline = true,
            update_in_insert = true
        })
    }
}

vim.cmd('colorscheme gruvbox')
