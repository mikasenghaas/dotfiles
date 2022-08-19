-- treesitter.rc.lua
--  configs for tree sitter
-- by: Mika Senghaas

local status, ts = pcall(require, "nvim-treesitter.configs")
if (not status) then return end

ts.setup {
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
    "lua"
  },

  auto_install = true,

  highlight = {
    enable = true,
    disable = {},
  },

  indent = {
    enable = true,
    disable = { "python" },
  },

  autotag = {
    enable = true,
  },
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
