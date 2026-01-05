return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.lsp.config('clangd', {
                cmd = {
                    "clangd",
                    "--header-insertion=never",
                    "--compile-commands-dir=build",
                    "--all-scopes-completion",
                    "--background-index"
                }
            })
            vim.lsp.enable('clangd')

            vim.lsp.config('cmake', {})
            vim.lsp.enable('cmake')

            vim.lsp.config('yamlls', {})
            vim.lsp.enable('yamlls')

            vim.lsp.config('jsonls', {
                cmd = {
                    "vscode-json-languageserver",
                    "--stdio"
                },
            })
            vim.lsp.enable('jsonls')

            vim.lsp.config('pylsp', {})
            vim.lsp.enable('pylsp')

        end
    }
}
