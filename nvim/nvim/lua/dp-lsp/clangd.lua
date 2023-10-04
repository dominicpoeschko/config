require 'lspconfig'.clangd.setup {
    cmd = {
        "clangd",
        "--header-insertion=never",
        "--compile-commands-dir=build",
        "--all-scopes-completion",
        "--background-index",
        "--enable-config"
    },
    on_attach = require 'dp-lsp'.common_on_attach,
    handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            virtual_text = false,
            signs = true,
            underline = true,
            update_in_insert = true
        })
    }
}
