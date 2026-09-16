return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        ft = { "markdown" },
        opts = {
            -- raw text reappears on the cursor line so editing stays honest
            anti_conceal = { enabled = true },
            -- LaTeX rendering needs `latex2text` (python-pylatexenc); out of scope
            latex = { enabled = false },
            -- no html/yaml treesitter parsers installed (see nvim-treesitter spec
            -- in my.lua); re-enable these once parsers are actually being installed
            html = { enabled = false },
            yaml = { enabled = false },
            completions = { lsp = { enabled = true } },
        },
    },
}
