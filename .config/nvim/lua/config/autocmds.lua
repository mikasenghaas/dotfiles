-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- .tex file settings
vim.cmd([[
  autocmd FileType tex setlocal textwidth=80
  autocmd FileType tex setlocal colorcolumn=+1
  autocmd FileType tex setlocal wrap
]])
