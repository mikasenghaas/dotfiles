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
          on_new_config = function(config)
            -- Remove auto-associated schemas for tasks.json
            local schemas = config.settings.json.schemas or {}
            config.settings.json.schemas = vim.tbl_filter(function(schema)
              return not vim.tbl_contains(schema.fileMatch or {}, "tasks.json")
            end, schemas)
          end,
        },
        basedpyright = {
          before_init = function(_, config)
            local venv = vim.fn.getcwd() .. "/.venv"
            if vim.fn.isdirectory(venv) == 1 then
              config.settings.python.pythonPath = venv .. "/bin/python"
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
      setup = {},
    },
  },
}
