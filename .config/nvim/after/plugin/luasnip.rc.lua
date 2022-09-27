-- luasnip.rc.lua
--  settings for luasnip (the snippet engine written in lua)
-- by: mika senghaas

local status, ls = pcall(require, 'luasnip')
if (not status) then return end

-- load vscode-like snippets (configured in json) from rafamadriz/friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- load custom snippets (configured in lua)
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/luasnippets/" })

ls.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
  enable_autosnippets = true
})

-- keymap
vim.keymap.set({ "i", "s" }, "<C-j>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  elseif ls.choice_active() then
    ls.change_choice(1)
  end
end, { silent = true })
