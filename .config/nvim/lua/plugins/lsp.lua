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
        virtual_text = { current_line = true },
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
          -- uv returns the project .venv, else an installed interpreter that satisfies requires-python.
          -- Without it, basedpyright falls back to the system python and its older language version.
          before_init = function(_, config)
            local ok, res = pcall(function()
              return vim.system({ "uv", "python", "find" }, { cwd = config.root_dir, text = true }):wait()
            end)
            if ok and res.code == 0 then
              config.settings.python = vim.tbl_extend("force", config.settings.python or {}, {
                pythonPath = vim.trim(res.stdout),
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
