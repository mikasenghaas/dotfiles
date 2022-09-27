-- lsp-installer.rc.lua
-- by: Mika Senghaas

local status, installer = pcall(require, "lsp-installer")
if (not status) then return end

installer.setup({
  automatic_installation = true;
})
