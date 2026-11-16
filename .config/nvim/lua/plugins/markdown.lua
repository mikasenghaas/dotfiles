return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      -- Neovim wraps on the raw text, so concealed link URLs break lines early.
      win_options = { conceallevel = { rendered = 0 } },
      code = { inline = false },
      bullet = { enabled = false },
      link = { enabled = false },
    },
  },
}
