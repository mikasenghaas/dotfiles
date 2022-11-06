-- maps.lua
--  key mappings
-- by: mika senghaas

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- change leader to space
vim.g.mapleader = ' '

-- disable arrow keys
map('', '<up>', '<nop>')
map('', '<down>', '<nop>')
map('', '<left>', '<nop>')
map('', '<right>', '<nop>')

-- change modes
map('i', 'kj', '<esc>')
map('v', 'iu', '<esc>')

-- change yank on delete
map('n', 'x', '"_x')

-- tabs
map('n', 'te', ':tabedit ')
map('n', '<leader>n', ':tabedit<cr>')
map('n', 'J', ':tabp<cr>')
map('n', 'K', ':tabn<cr>')

-- splits
map('n', 'ss', ':split<cr><C-w>w')
map('n', 'sv', ':vsplit<cr><C-w>w')

-- select all
map('n', '<leader>a', 'gg<S-v>G')
