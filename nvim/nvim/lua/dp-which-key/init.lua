require("which-key").setup {
    plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
            operators = true, -- adds help for operators like d, y, ...
            motions = true, -- adds help for motions
            text_objects = true, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true, -- misc bindings to work with windows
            z = true, -- bindings for folds, spelling and others prefixed with z
            g = true -- bindings for prefixed with g
        }
    },
    icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+" -- symbol prepended to a group
    },
    window = {
        border = "single", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 2, 2, 2, 2 } -- extra window padding [top, right, bottom, left]
    },
    layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3 -- spacing between columns
    },
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
    show_help = true -- show help message on the command line when the popup is visible
}

local opts = {
    mode = "n", -- NORMAL mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = false -- use `nowait` when creating keymaps
}

-- Set leader
vim.api.nvim_set_keymap('n', '<Space>', '<NOP>', { noremap = true, silent = true })
vim.g.mapleader = ' '

-- telescope
vim.api.nvim_set_keymap('n', '<Leader>f', ':Telescope smart_open<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>d', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>r', ':Telescope neoclip a extra=star,plus,b<CR>', { noremap = true, silent = true })

-- close buffer
vim.api.nvim_set_keymap("n", "<leader>c", ":BufferClose<CR>", { noremap = true, silent = true })

-- better window movement
vim.api.nvim_set_keymap('n', '<C-Left>', '<C-w>h', { silent = true })
vim.api.nvim_set_keymap('n', '<C-Right>', '<C-w>l', { silent = true })

-- Tab switch buffer
vim.api.nvim_set_keymap('n', '<A-Left>', ':BufferPrevious<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-Right>', ':BufferNext<CR>', { noremap = true, silent = true })

local mappings = {
    ["c"] = "close buffer",
    ["f"] = "find file",
    ["r"] = "show registers",

    g = {
        name = "+Goto",
        d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "definition" },
        c = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "declaration" },
    },

    l = {
        name = "+LSP",
        a = { "<cmd>Telescope lsp_code_actions<cr>", "list code actions" },
        f = { "<cmd>lua if vim.bo.filetype == 'cpp' or vim.bo.filetype == 'c' then vim.cmd('ClangFormat') else vim.lsp.buf.format() end<cr>", "format" },
        i = { "<cmd>lua vim.lsp.buf.hover()<cr>", "hover info" },

        h = { "<cmd>lua vim.lsp.buf.document_highlight()<cr>", "highlight symbol" },
        c = { "<cmd>lua vim.lsp.buf.clear_references()<cr>", "clear highlight" },

        l = { "<cmd>LspInfo<cr>", "client infos" },
        d = { "<cmd>lua vim.diagnostic.open_float()<cr>", "show line diagnostics" },

        r = { "<cmd>Telescope lsp_references<cr>", "list symbols references" },
        s = { "<cmd>Telescope lsp_document_symbols<cr>", "list document symbols" },
    },
    s = {
        name = "+Search",
        s = { ":%s///gc<Left><Left><Left><Left>", "search and replace", silent = false },
        p = { "<cmd>lua require('spectre').toggle()<cr>", "spectre" },
        r = { "<cmd>Telescope oldfiles<cr>", "open recent files" },
        t = { "<cmd>Telescope live_grep<cr>", "grep" }
    },
}

local wk = require("which-key")
wk.register(mappings, opts)
