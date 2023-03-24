-- lsp.lua
--  configs for nvim language server (lspconfig, mason, lspkind, lspsaga)
-- by: mika senghaas

local status, nvim_lsp = pcall(require, "lspconfig")
if (not status) then print("lsp config not available") return end

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
    virtual_text = false,
    signs = false,
    underline = false,
    update_in_insert = false,
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

-- lspsaga (performant ui for lsp features)
local status_saga, saga = pcall(require, "lspsaga")
if (not status_saga) then print("lspsaga config not available") return end

saga.setup({})

-- lsp saga remaps
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<C-j>', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
vim.keymap.set('n', '<C-k>', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
vim.keymap.set('n', 'gd', '<Cmd>Lspsaga lsp_finder<CR>', opts)
vim.keymap.set('n', 'gt', '<Cmd>Lspsaga goto_definition<CR>', opts)
vim.keymap.set('n', 'gp', '<Cmd>Lspsaga preview_definition<CR>', opts)
vim.keymap.set('n', 'gr', '<Cmd>Lspsaga rename<CR>', opts)
vim.keymap.set('n', 'ga', '<cmd>Lspsaga code_action<CR>', opts)

-- null-ls (formatting and linting)
local null_ls_status, null_ls = pcall(require, "null-ls")
if (not status) then print("null-ls is not available") return end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
  debug = False,
  sources = {
    -- formatting
    formatting.prettier, -- js/ts
    formatting.black, -- py
    formatting.latexindent, -- tex

    -- diagnostics
    diagnostics.ruff, -- py
    diagnostics.chktex.with({ extra_args = { "-n", "24" } }) -- tex
  }
})

function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }  
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- format with leader-f
map("n", "<leader>f", ":lua vim.lsp.buf.format()<CR>")
