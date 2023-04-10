-- settings if filetype .md
vim.opt.textwidth = 80 -- 80 textwidth
vim.opt.colorcolumn = "+1" -- colorcolumn one char after textwidth
vim.opt.wrap = true  -- soft line wrapping
vim.opt.spell = true  -- underline spelling mistakes 
vim.opt.spelllang = 'en_gb' -- use british english

-- correct previous spelling mistakes
vim.api.nvim_set_keymap('i', '<C-l>', [[<Esc>[s1z=`]a]], {noremap = true})
vim.api.nvim_set_keymap('n', '<C-l>', [[[s1z=`]]], {noremap = true})

