-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_explorer = "snacks"
vim.g.lazyvim_python_lsp = "basedpyright"

-- Monorepos nest a pyproject.toml per package, so an LSP root would scope pickers to one package.
vim.g.root_spec = { { ".git" }, "lsp", "cwd" }

-- No conceal
vim.opt.conceallevel = 0

-- No smooth scroll
vim.opt.smoothscroll = false

-- Disable automatic commenting on newlines
vim.api.nvim_create_autocmd("BufWinEnter", {
  command = "set formatoptions-=o",
})

-- Disable inline diagnostic virtual text
vim.diagnostic.config({
  virtual_text = false,
})
