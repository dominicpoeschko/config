-- TODO figure out why this don't work
vim.fn.sign_define(
    "LspDiagnosticsSignError",
    { texthl = "LspDiagnosticsSignError", text = "", numhl = "LspDiagnosticsSignError" }
)
vim.fn.sign_define(
    "LspDiagnosticsSignWarning",
    { texthl = "LspDiagnosticsSignWarning", text = "", numhl = "LspDiagnosticsSignWarning" }
)
vim.fn.sign_define(
    "LspDiagnosticsSignHint",
    { texthl = "LspDiagnosticsSignHint", text = "", numhl = "LspDiagnosticsSignHint" }
)
vim.fn.sign_define(
    "LspDiagnosticsSignInformation",
    { texthl = "LspDiagnosticsSignInformation", text = "", numhl = "LspDiagnosticsSignInformation" }
)

-- Set Default Prefix.
-- Note: You can set a prefix per lsp server in the lv-globals.lua file
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {
        prefix = "",
        spacing = 0,
    },
    signs = true,
    underline = true,
}
)

local lsp_config = {}

--function lsp_config.common_on_attach(client, bufnr)
--    documentHighlight(client, bufnr)
--end

function lsp_config.tsserver_on_attach(client, bufnr)
    lsp_config.common_on_attach(client, bufnr)
    client.resolved_capabilities.document_formatting = true
end

return lsp_config
