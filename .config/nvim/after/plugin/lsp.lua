-- lsp.lua
--  configs for nvim language server (lspconfig, mason, lspkind, lspsaga)
-- by: mika senghaas

local status, nvim_lsp = pcall(require, "lspconfig")
if (not status) then
  print("lsp config not available")
  return
end

local on_attach = function(_, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.hover, bufopts)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- javascipt/ typescript
nvim_lsp.tsserver.setup {
  filetypes = { "javascript", "javascriptrect", "typescript", "typescriptreact", "typescript.tsx" },
  capabilities = capabilities
}

-- tailwind
nvim_lsp.tailwindcss.setup { on_attach = on_attach, capabilities = capabilities }

-- astro
nvim_lsp.astro.setup { on_attach = on_attach, capabilities = capabilities }

-- css
nvim_lsp.cssls.setup { on_attach = on_attach, capabilities = capabilities }

-- json lanaguage
nvim_lsp.jsonls.setup { on_attach = on_attach, capabilities = capabilities }

-- lua
nvim_lsp.lua_ls.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }, -- recognise vim global
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false
      },
    },
  },
}

-- python language server
nvim_lsp.pyright.setup {
  on_attach = on_attach,
  autostart = false,
  settings = {
    python = {
      analysis = {
        diagnosticMode = "off",
        typeCheckingMode = "off"
      }
    }
  } }

-- r language server
nvim_lsp.r_language_server.setup { on_attach = on_attach }

-- clangd (c language server)
nvim_lsp.clangd.setup { on_attach = on_attach, autostart = false }

-- clangd (c language server)
nvim_lsp.rust_analyzer.setup { on_attach = on_attach }

-- set diagnostics to update in insert mode
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    update_in_insert = false,
    virtual_text = { spacing = 4, prefix = "●" },
    severity_sort = true,
  }
)

-- change diagnostic symbols in the sign column
local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- display diagnostic with prefix
vim.diagnostic.config({
  virtual_text = false,
  update_in_insert = true,
  float = {
    source = "always", -- Or "if_many"
  },
})

-- setup mason
require("mason").setup({})
require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",       -- python
    "rust_analyzer", -- rust
    "jdtls",         -- java
    "clangd",        -- c
    "cmake",         -- makefiles
    "marksman",      -- markdown
  },
  automatic_installation = true,
})

-- lspsaga (performant ui for lsp features)
local status_saga, saga = pcall(require, "lspsaga")
if (not status_saga) then
  print("lspsaga config not available")
  return
end

saga.setup({})

-- lsp saga remaps
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<C-j>', ':lua vim.diagnostic.goto_next()<CR>', opts)
vim.keymap.set('n', '<C-k>', ':lua vim.diagnostic.goto_prev()<CR>', opts)
-- vim.keymap.set('n', 'gd', '<Cmd>Lspsaga hover_doc<CR>', opts) -- using default neovim
vim.keymap.set('n', 'gt', '<Cmd>Lspsaga lsp_finder<CR>', opts)
vim.keymap.set('n', 'gp', '<Cmd>Lspsaga preview_definition<CR>', opts)
vim.keymap.set('n', 'gr', '<Cmd>Lspsaga rename<CR>', opts)
-- vim.keymap.set('n', 'ga', '<cmd>Lspsaga code_action<CR>', opts)

-- null-ls (formatting and linting)
local null_ls_status, null_ls = pcall(require, "null-ls")
if (not null_ls_status) then
  print("null-ls is not available")
  return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
  debug = false,
  sources = {
    -- formatting
    formatting.prettier,    -- js/ts
    formatting.black,       -- py
    formatting.latexindent, -- tex

    -- diagnostics
    diagnostics.ruff,                                                               -- py
    diagnostics.chktex.with({ extra_args = { "-n", "24", "-n", "8", "-n", "1" } }), -- tex
    -- diagnostics.proselint, -- tex
  }
})

-- format with leader-f
vim.api.nvim_set_keymap("n", "<leader>f", ":lua vim.lsp.buf.format()<CR>", { noremap = true, silent = true })
