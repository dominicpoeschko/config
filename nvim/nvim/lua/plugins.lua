local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
    execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
    execute "packadd packer.nvim"
end

--- Check if a file or directory exists in this path
local function require_plugin(plugin)
    local plugin_prefix = fn.stdpath("data") .. "/site/pack/packer/opt/"

    local plugin_path = plugin_prefix .. plugin .. "/"
    --	print('test '..plugin_path)
    local ok, err, code = os.rename(plugin_path, plugin_path)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    --	print(ok, err, code)
    if ok then
        vim.cmd("packadd " .. plugin)
    end
    return ok, err, code
end

return require("packer").startup(
    function(use)
        -- Packer can manage itself as an optional plugin
        use { "wbthomason/packer.nvim" }

        use { "neovim/nvim-lspconfig", opt = true }

        -- Telescope
        use { "nvim-lua/popup.nvim", opt = true }
        use { "nvim-lua/plenary.nvim", opt = true }
        use { "nvim-telescope/telescope.nvim", opt = true }

        use {
            "danielfalk/smart-open.nvim",
            requires = {
                { "kkharji/sqlite.lua" },
                { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
                { "nvim-telescope/telescope-fzy-native.nvim" },
            }
        }

        -- spellcheck
        use { 'lewis6991/spellsitter.nvim', opt = true }

        -- Autocomplete
        use { 'hrsh7th/cmp-nvim-lsp', opt = true }
        use { 'hrsh7th/cmp-buffer', opt = true }
        use { 'hrsh7th/cmp-path', opt = true }
        use { 'hrsh7th/cmp-nvim-lsp-signature-help', opt = true }
        use { "hrsh7th/nvim-cmp", opt = true }

        -- Register clipboard
        use { "AckslD/nvim-neoclip.lua", opt = true }

        -- Treesitter
        use { "nvim-treesitter/nvim-treesitter", opt = true, run = ":TSUpdate" }

        -- Git
        use { "lewis6991/gitsigns.nvim", opt = true }
        use { "tpope/vim-fugitive", opt = true }

        -- Keymappings
        use { "folke/which-key.nvim", opt = true }

        -- Better quick fix
        use { "kevinhwang91/nvim-bqf", opt = true }

        -- Color
        use { "rktjmp/lush.nvim", opt = true }
        use { "ellisonleao/gruvbox.nvim", opt = true }
        use { "EdenEast/nightfox.nvim", opt = true }

        -- Scrollbar
        use { "dstein64/nvim-scrollview", opt = true }

        -- Multi Cursor
        use { "mg979/vim-visual-multi", opt = true }

        -- Indent Guides
        use { "lukas-reineke/indent-blankline.nvim", opt = true }

        -- Icons
        use { "kyazdani42/nvim-web-devicons", opt = true }

        -- Status Line and Bufferline
        use { "glepnir/galaxyline.nvim", opt = true }
        use { "romgrk/barbar.nvim", opt = true }

        -- Whitespace
        use { "ntpeters/vim-better-whitespace", opt = true }

        use { "mickael-menu/zk-nvim", opt = true }

        use { "rhysd/vim-clang-format", opt = true }

        use { "HiPhish/rainbow-delimiters.nvim", opt = true }

        require_plugin("nvim-lspconfig")
        require_plugin("popup.nvim")
        require_plugin("plenary.nvim")
        require_plugin("telescope.nvim")
        require_plugin("spellsitter.nvim")
        require_plugin("cmp-nvim-lsp")
        require_plugin("cmp-buffer")
        require_plugin("cmp-path")
        require_plugin("cmp-nvim-lsp-signature-help")
        require_plugin("nvim-cmp")
        require_plugin("nvim-treesitter")
        require_plugin("gitsigns.nvim")
        require_plugin("vim-fugitive")
        require_plugin("which-key.nvim")
        require_plugin("nvim-bqf")
        require_plugin("lush.nvim")
        require_plugin("gruvbox.nvim")
        require_plugin("nightfox.nvim")
        require_plugin("nvim-scrollview")
        require_plugin("vim-visual-multi")
        require_plugin("indent-blankline.nvim")
        require_plugin("nvim-web-devicons")
        require_plugin("galaxyline.nvim")
        require_plugin("barbar.nvim")
        require_plugin("vim-better-whitespace")
        require_plugin("nvim-neoclip.lua")
        require_plugin("zk-nvim")
        require_plugin("vim-clang-format")
        require_plugin("rainbow-delimiters.nvim")
        require_plugin("kkharji/sqlite.lua")
    end
)
