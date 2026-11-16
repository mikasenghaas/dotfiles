return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        formatters = { file = { filename_first = true } },
      },
    },
    keys = {
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files (Frecency)" },
      { "<leader>ff", function() Snacks.picker.smart() end, desc = "Smart Find Files (Frecency)" },
    },
  },
}
