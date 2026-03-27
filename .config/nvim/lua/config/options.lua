-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Use Copilot ghost text instead of completion menu
vim.g.ai_cmp = false

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
