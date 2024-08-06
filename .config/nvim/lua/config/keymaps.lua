-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Disabling arrow keys
keymap.set("", "<up>", "<nop>", opts)
keymap.set("", "<down>", "<nop>", opts)
keymap.set("", "<left>", "<nop>", opts)
keymap.set("", "<right>", "<nop>", opts)

-- Select all
keymap.set("n", "<leader>a", "gg<S-v>G", opts)

-- Splits
keymap.set("n", "ss", ":split<CR>", opts)
keymap.set("n", "sv", ":vsplit<CR>", opts)
