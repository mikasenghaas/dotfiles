-- set skim as pdf viewer
vim.g.vimtex_view_method = "skim"
vim.g.vimtex_view_general_viewer = "skim"
vim.g.vimtex_view_forward_search_on_start = true

-- compilation options
vim.g.vimtex_compiler_latexmk = {
  build_dir = 'build'
}

-- keymaps for auto compile and forward search
vim.keymap.set('n', '<localleader>c', "<plug>(vimtex-compile)")
vim.keymap.set('n', '<localleader>v', "<plug>(vimtex-view)")
