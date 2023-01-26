-- autopair.lua
--  configs for autopair
-- by: mika senghaas

local status, autopairs = pcall(require, "nvim-autopairs")
if (not status) then return end

print('autopairs')
autopairs.setup({
  disable_filetype = { "TelescopePrompt", "vim" },
})
