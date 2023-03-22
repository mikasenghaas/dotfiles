-- lsp.lua
--  configs for nvim language server (lspconfig, mason, lspkind, lspsaga)
-- by: mika senghaas

local status, nvim_lsp = pcall(require, "lspconfig")
if (not status) then print("lsp config not available") return end

saga = require("lspsaga")
mason = require("mason")

local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gk', vim.lsp.buf.hover, bufopts)
end

-- javascipt/ typescript
nvim_lsp.tsserver.setup {
  filetypes = { "javascript", "javascriptrect", "typescript", "typescriptreact", "typescript.tsx" }
}

-- tailwind
nvim_lsp.tailwindcss.setup { on_attach = on_attach }

-- tailwind
nvim_lsp.astro.setup { on_attach = on_attach }

-- css
nvim_lsp.cssls.setup { on_attach = on_attach }

-- json lanaguage
nvim_lsp.jsonls.setup { on_attach = on_attach }

-- python language server
nvim_lsp.pyright.setup{ on_attach = on_attach }

-- r language server
nvim_lsp.r_language_server.setup{ on_attach = on_attach }

-- clangd (c language server)
nvim_lsp.clangd.setup { on_attach = on_attach, autostart = false }

-- clangd (c language server)
nvim_lsp.rust_analyzer.setup { on_attach = on_attach }

-- set diagnostics to update in insert mode
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = false,
    underline = true,
    update_in_insert = true,
})

-- setup mason
require("mason").setup({})
require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright", -- python
    "rust_analyzer", -- rust
    "jdtls", -- java
    "clangd", -- c
    "cmake", -- makefiles
    "marksman", -- markdown
  },
  automatic_installation = true,
})

-- setup lspsaga (performant ui for lsp features)
-- saga.init_lsp_saga()

-- lsp saga remaps
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<C-j>', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
vim.keymap.set('n', '<C-k>', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
vim.keymap.set('n', 'ca', '<cmd>Lspsaga code_action<CR>', opts)
vim.keymap.set('n', 'gd', '<Cmd>Lspsaga lsp_finder<CR>', opts)
vim.keymap.set('i', '<C-h>', '<Cmd>Lspsaga signature_help<CR>', opts)
vim.keymap.set('n', 'gp', '<Cmd>Lspsaga preview_definition<CR>', opts)
vim.keymap.set('n', 'gr', '<Cmd>Lspsaga rename<CR>', opts)
