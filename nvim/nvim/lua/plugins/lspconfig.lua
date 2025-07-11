return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("lspconfig").clangd.setup {
                cmd = {
                    "clangd",
                    "--header-insertion=never",
                    "--compile-commands-dir=build",
                    "--all-scopes-completion",
                    "--background-index"
                },
                handlers = {
                    ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
                        virtual_text = false,
                        signs = true,
                        underline = true,
                        update_in_insert = true
                    })
                }
            }

            require("lspconfig").cmake.setup {}
            require("lspconfig").yamlls.setup {}
            require("lspconfig").jsonls.setup {
                cmd = {
                    "vscode-json-languageserver",
                    "--stdio"
                },
            }
            require("lspconfig").pylsp.setup {}
        end
    }
}