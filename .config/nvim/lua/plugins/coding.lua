return {
  -- Disable blink.cmp completion popup
  {
    "saghen/blink.cmp",
    enabled = false,
  },

  -- Copilot: Tab to accept ghost text, fallback to normal Tab
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
    },
    keys = {
      {
        "<Tab>",
        function()
          if require("copilot.suggestion").is_visible() then
            require("copilot.suggestion").accept()
          else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
          end
        end,
        mode = "i",
        desc = "Accept Copilot or normal Tab",
      },
    },
  },
}
