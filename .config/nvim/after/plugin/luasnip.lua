-- luasnip.lua
--  settings for snippet engine
-- by: mika senghaas

local status, luasnip = pcall(require, 'luasnip')
if (not status) then return end

-- load vscode-like snippets (configured in json) from rafamadriz/friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- load custom snippets (configured in lua)
require("luasnip.loaders.from_lua").load({
  paths = "~/.config/nvim/luasnippets/"
})

luasnip.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
  enable_autosnippets = true
})

-- keymap
vim.cmd("imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' ")
