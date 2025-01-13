return {
    {
        "ellisonleao/gruvbox.nvim"
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim"
        }
    },
    {
        "danielfalk/smart-open.nvim",
        dependencies = {
            { "kkharji/sqlite.lua" },
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            { "nvim-telescope/telescope-fzy-native.nvim" },
        }
    },
    {
        "romgrk/barbar.nvim",
        dependencies = {
            "lewis6991/gitsigns.nvim",
            "nvim-tree/nvim-web-devicons"
        }
    },
    {
        "folke/which-key.nvim"
    },
    {
        "mg979/vim-visual-multi"
    },
    {
        "lukas-reineke/indent-blankline.nvim",
    },
    {
        "HiPhish/rainbow-delimiters.nvim"
    },
    {
        "dstein64/nvim-scrollview"
    },
    {
        "lewis6991/gitsigns.nvim"
    },
    {
        "ntpeters/vim-better-whitespace"
    },
    {
        "rhysd/vim-clang-format"
    },
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        event = "BufRead",
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = {"c", "cpp", "python", "lua", "yaml", "json", "markdown", "markdown_inline"},
                highlight = {
                    enable = true
                },
            }
        end
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp-signature-help",
        },
        opts = function()
            local cmp = require("cmp")
            return {
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Auswahl bestätigen
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = "nvim_lsp_signature_help" },
                    { name = "buffer" },
                }),
            }
        end,
    },
    {
        "neovim/nvim-lspconfig"
    }
}
