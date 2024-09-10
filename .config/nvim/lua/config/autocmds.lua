-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- LaTeX file settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex" },
  callback = function()
    vim.opt_local.wrap = true -- Enable visual line wrapping
    vim.opt_local.textwidth = 80 -- Set textwidth
    vim.opt_local.colorcolumn = "80" -- Enable colorcolumn
  end,
})

-- Markdown file settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true -- Enable visual line wrapping
    vim.opt_local.linebreak = true -- Wrap lines at word boundaries
  end,
})
