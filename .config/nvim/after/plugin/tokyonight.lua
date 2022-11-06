-- tokyonight.lua
--  settings for tokyonight colorscheme
-- by: mika senghaas

local status, tn = pcall(require, 'tokyonight')
if (not status) then return end

tn.setup({
  style = "storm",
  transparent = true,
  terminal_colors = false,
  styles = {
    comments = { italic = true },
    keywords = { italic = false },
    functions = {},
    variables = {},
    sidebars = "dark", 
    floats = "dark",
  },
})

vim.cmd('colorscheme tokyonight-moon')
