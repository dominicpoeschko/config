vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.clipboard = "unnamedplus"
vim.wo.number = true

vim.cmd('set ts=4')
vim.cmd('set sw=4')
vim.cmd('set expandtab')
vim.cmd('set nospell')

require("config.lazy")

vim.keymap.set({"n", "v"}, "<leader>r", ":%s///gc<Left><Left><Left><Left>", {desc = "Search and Replace", silent = false})
vim.keymap.set("n", "<Leader>f", ":Telescope find_files<CR>", {noremap = true, silent = true})

--function lsp_config.tsserver_on_attach(client, bufnr)
--    lsp_config.common_on_attach(client, bufnr)
--    client.resolved_capabilities.document_formatting = true
--end

require 'lspconfig'.clangd.setup {
    cmd = {
        "clangd",
        "--header-insertion=never",
        "--compile-commands-dir=build",
        "--all-scopes-completion",
        "--background-index",
        "--enable-config"
    },
    --on_attach = require 'dp-lsp'.common_on_attach,
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
