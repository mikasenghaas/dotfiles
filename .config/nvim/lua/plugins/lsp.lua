return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {}, -- Leave empty to disable auto-install
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        -- Example: Lazy-load LSP servers for specific filetypes
        tsserver = function(_, opts)
          opts.ft = { "javascript", "typescript" }
          return true
        end,
        pyright = function(_, opts)
          opts.ft = { "python" }
          return false
        end,
      },
    },
  },
}
