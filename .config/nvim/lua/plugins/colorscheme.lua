return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    opts = { disable_background = true },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = { transparent_background = true },
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = { transparent = true },
  },
  {
    "shaunsingh/nord.nvim",
    lazy = true,
    config = function()
      vim.g.nord_disable_background = true
    end,
  },
  {
    "rockyzhang24/arctic.nvim",
    lazy = true,
    dependencies = { "rktjmp/lush.nvim" },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  -- Configure LazyVim to load colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      -- Options: "tokyonight-night", "tokyonight-storm", "tokyonight-moon",
      --          "catppuccin-mocha", "rose-pine", "kanagawa", "nord"
      colorscheme = "tokyonight-moon",
    },
  },
}
