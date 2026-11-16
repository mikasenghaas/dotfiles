local markdownlint_configs = {
  ".markdownlint-cli2.yaml",
  ".markdownlint-cli2.jsonc",
  ".markdownlint-cli2.cjs",
  ".markdownlint.yaml",
  ".markdownlint.yml",
  ".markdownlint.json",
  ".markdownlint.jsonc",
}

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          -- Lint the file on disk: per-file overrides in the project config never match stdin.
          stdin = false,
          append_fname = false,
          args = {
            function()
              return vim.api.nvim_buf_get_name(0)
            end,
          },
          parser = require("lint.parser").from_errorformat("%f:%l:%c %m,%f:%l %m", {
            source = "markdownlint",
            severity = vim.diagnostic.severity.WARN,
          }),
          -- The default rules flag line length and inline HTML, so lint only projects that opt in.
          condition = function(ctx)
            return vim.fs.find(markdownlint_configs, { path = ctx.dirname, upward = true })[1] ~= nil
          end,
        },
      },
    },
  },
}
