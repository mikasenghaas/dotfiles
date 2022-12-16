" base vim config
" by: mika senghaas

" general
set title
set encoding=utf-8
set undodir=~/.vim/undodir
set mouse=a
set nobackup
set nowrap
set scrolloff=10

" syntax
syntax on
 
" search
set incsearch
set nohlsearch

" splits
set splitbelow
set splitright

" numbering
set number
set relativenumber
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmode
set showcmd
set backspace=indent,eol,start

" tab and indent
set smartindent
set expandtab " press to tab inserts spaces
set tabstop=2 " amount of spaces to insert on tab
set shiftwidth=2 " indents correctly on newline
set softtabstop=2
set formatoptions=crql
set noshiftround

" disable error bells
set noerrorbells
set belloff=all

" cursor
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
