-- base.lua
--  base settings for nvim
-- by: mika senghaas

-- set autocmd
vim.cmd("autocmd!")
vim.cmd("autocmd BufEnter * set formatoptions-=o")

-- encodings
vim.scriptencoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- shell
vim.opt.shell = 'fish'

-- line number
vim.wo.number = true -- current line is highlighted
vim.opt.relativenumber = true -- relative line numbering

-- tabs + indentation
vim.opt.autoindent = true -- automatically indent
vim.opt.tabstop = 2 -- \t uses 2 two whitespaces
vim.opt.softtabstop = 2 -- number of spaces of tab when editing
vim.opt.shiftwidth = 2  -- number of spaces for auto indent
vim.opt.expandtab = true -- use spaces on press to tab
vim.opt.smarttab = true -- use shiftwidth when inserting spaces on press to tab

-- searching
vim.opt.ignorecase = true -- ignore casing on search
vim.opt.hlsearch = true -- highlight search matches

vim.opt.backspace = { 'start', 'eol', 'indent' }
vim.opt.backup = false
vim.opt.backupskip = { '/tmp/*', '/private/tmp/*' }

-- look/ feel
vim.opt.title = true
vim.opt.wrap = false -- no line wrapping
vim.opt.cmdheight = 1 -- height of command line
vim.opt.laststatus = 2 -- makes lualine also show in split views
vim.opt.scrolloff = 5 -- leave 5 lines space when scrolling
vim.opt.signcolumn = 'yes' -- always display sign column for diagnostics

-- set mouse
vim.opt.mouse = 'a'

-- fsharp-ionide
vim.cmd [[
  let g:fsharp#fsi_keymap = "vim-fsharp"
]]
