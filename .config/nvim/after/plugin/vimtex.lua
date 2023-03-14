vim.g.vimtex_view_method = "skim"
vim.g.vimtex_view_general_viewer = "skim"
vim.g.vimtex_view_forward_search_on_start = true

vim.keymap.set('n', '<localleader>c', "<plug>(vimtex-compile)")
vim.keymap.set('n', '<localleader>v', "<plug>(vimtex-view)")
