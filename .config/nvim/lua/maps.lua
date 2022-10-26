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

-- exit files
map('n', '<leader>q', ':q<cr>')
map('n', '<leader>s', ':w<cr>')
map('n', '<leader>sq', ':wq<cr>')

-- tabs
map('n', 'te', ':tabedit ')
map('n', '<leader>n', ':tabedit<cr>')
map('n', 'J', ':tabp<cr>')
map('n', 'K', ':tabn<cr>')

-- splits
map('n', 'ss', ':split<cr><C-w>w')
map('n', 'sv', ':vsplit<cr><C-w>w')

-- move lines
map('v', '<C-j>', ":m '>+1<cr>gv")
map('v', '<C-k>', ":m '<-2<cr>gv")

-- increment/ decrement
map('n', '+', '<C-a>')
map('n', '-', '<C-x>')

-- delete backwards
map('n', 'dw', 'vb"_d')

-- select all
map('n', '<leader>a', 'gg<S-v>G')
