-- autotag.rc.lua
--  configs for autotag
-- by: Mika Senghaas

local status, autotag = pcall(require, "nvim-ts-autotag")
if (not status) then return end

autotag.setup({
  filetypes = {
    "html",
    "xml",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "svelte",
    "tsx",
    "jsx",
    "markdown",
  }
})
