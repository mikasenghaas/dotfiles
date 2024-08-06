return {
  -- Noice
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      table.insert(opts.routes, {
        filter = { find = "yanked" },
        opts = { skip = true },
      })
      table.insert(opts.routes, {
        filter = { find = "more lines" },
        opts = { skip = true },
      })
      table.insert(opts.routes, {
        filter = { find = "less lines" },
        opts = { skip = true },
      })

      -- Set border for lsp hover
      opts.presets.lsp_doc_border = true
    end,
  },

  -- Incline
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
