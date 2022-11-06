-- treesitter.lua
--  configs for tree sitter
-- by: Mika Senghaas

local status, treesitter = pcall(require, "nvim-treesitter.configs")
if (not status) then return end

treesitter.setup {
  ensure_installed = {
    "tsx",
    "toml",
    "fish",
    "php",
    "json",
    "yaml",
    "python",
    "swift",
    "css",
    "html",
    "lua",
    "make"
  },

  auto_install = true,

  highlight = {
    -- find the highlighting quite ugly
    enable = false,
    disable = {},
  },

  indent = {
    -- more reliable than native lua indent
    enable = true,
    disable = { "python" },
  },

  autotag = {
    -- necessary to get autotag to work
    enable = true,
  },
}
