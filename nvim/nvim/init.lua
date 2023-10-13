vim.cmd('let g:better_whitespace_operator=""')
vim.cmd('let g:scrollview_auto_workarounds=0')

require('plugins')
require('settings')
require('dp-which-key')
require('dp-galaxy-line')
require('dp-cmp')

require("ibl").setup {}

require('neoclip').setup()
require('spellsitter').setup()
require('telescope').setup()

require('telescope').load_extension('neoclip')
require('telescope').load_extension("smart_open")

require('gitsigns').setup {
    signs = {
        -- TODO add hl to colorscheme
        add          = { hl = 'GitSignsAdd', text = '▎', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
        change       = { hl = 'GitSignsChange', text = '▎', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
        delete       = { hl = 'GitSignsDelete', text = '契', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
        topdelete    = { hl = 'GitSignsDelete', text = '契', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
        changedelete = { hl = 'GitSignsChange', text = '▎', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
    },
    numhl = false,
    linehl = false,
    watch_gitdir = {
        interval = 1000
    },
    sign_priority = 6,
    update_debounce = 200,
    status_formatter = nil, -- Use default
}

require('nvim-treesitter.configs').setup {
    ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
        enable = true -- false will disable the whole extension
    },
    indent = { enable = true },
    rainbow = {
        enable = true,
        -- list of languages you want to disable the plugin for
        disable = { },
        -- Which query to use for finding delimiters
        query = 'rainbow-parens',
        -- Highlight the entire buffer all at once
        strategy = require('ts-rainbow').strategy.global,
  }
}

require("zk").setup()

require('dp-lsp')
require('dp-lsp.clangd')
require 'lspconfig'.pyright.setup {}
require 'lspconfig'.cmake.setup {}
require 'lspconfig'.lua_ls.setup {}
require 'lspconfig'.bashls.setup {}
require'lspconfig'.tsserver.setup{}
require'lspconfig'.html.setup{}
require 'lspconfig'.jsonls.setup {
    cmd = {
        "vscode-json-languageserver",
        "--stdio"
    },
}

vim.cmd(
[[
    command WSudo : w ! env SUDO_ASKPASS=/usr/lib/ssh/x11-ssh-askpass sudo tee % > /dev/null
]])


vim.cmd([[command Q q]])
vim.cmd([[command WQ wq]])
vim.cmd([[command W w]])
vim.cmd([[command Wq wq]])
vim.cmd([[command Wa wa]])
vim.cmd([[command WA wa]])
