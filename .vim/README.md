# vim

While [`nvim`](https://github.com/mikasenghaas/dotfiles/main/.config/nvim) is my main editor, I still have a minimal vim setup that I use to have
a minmal set of base configurations and mappings to work efficiently. I use these both as a import settings for the Vim VSCode emulation and occassionally
when working on a remote machine without a `neovim` install. 

The `vim` binaries are installed via `brew` and are configured through the `vimrc`. It loads two simple vimscript files:

1. [`base.vim`](https://github.com/mikasenghaas/dotfiles/tree/main/.vim/base.vim): Contains base configurations for vim

2. [`maps.vim`](https://github.com/mikasenghaas/dotfiles/tree/main/.vim/maps.vim): Contains a minimal set of custom keybindings

*Note, that this vim configuration does not include any plugins, colorschemes or further configurations. My regular development environment is in nvim, so visit
those configs to get a more extensive configuration*.
