" maps.vim
" by: mika senghaas

" leader
let mapleader=' '

" change to normal mode persists cursor position
imap <Esc> <Esc>l

" remap change to normal mode
imap kj <Esc>
vmap iu <Esc>

" switch tabs
nnoremap <S-k> :bnext<cr>
nnoremap <S-j> :bprevious<cr>
nnoremap <leader>c :bd<cr>

" splits
nnoremap ss :split<cr>
nnoremap sv :vsplit<cr>
