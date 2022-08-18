-- prettier.rc.lua
--  configs for prettier
-- by: Mika Senghaas

local status, prettier = pcall(require, 'prettier')
if (not status) then return end

prettier.setup {
  bin = 'prettierd',
  filetypes = {
    'css',
    'scss',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'json',
    'less'
  }
}
