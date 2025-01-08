return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        enabled = false
      }
    }
  },

  {
    "ellisonleao/gruvbox.nvim"
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },

  {
    "ibhagwan/fzf-lua",
    opts = {
      files = {
        formatter = "path.filename_first",
      },
     },
  },
}
