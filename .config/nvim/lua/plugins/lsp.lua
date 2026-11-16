return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {}, -- Leave empty to disable auto-install
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      servers = {
        jsonls = {
          -- SchemaStore's "task.json" schema claims every tasks.json and flags unrelated files.
          before_init = function(_, config)
            config.settings.json.schemas = require("schemastore").json.schemas({ ignore = { "task.json" } })
          end,
        },
        basedpyright = {
          -- Root at the environment, not the nearest pyproject.toml: uv workspace members share the root .venv.
          root_markers = { ".venv", ".git" },
          before_init = function(_, config)
            local venv = config.root_dir .. "/.venv"
            if vim.fn.isdirectory(venv) == 1 then
              config.settings.python = vim.tbl_extend("force", config.settings.python or {}, {
                pythonPath = venv .. "/bin/python",
              })
            end
          end,
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
                diagnosticSeverityOverrides = {
                  reportUnusedParameter = "none",
                },
              },
            },
          },
        },
      },
    },
  },
}
