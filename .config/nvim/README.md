# neovim

[`neovim`](https://neovim.io/) is the next-generation vim. 

nvim is installed (with Python support) from the `Brewfile` and is configured using the `lua` language.

## :file_folder: Organisation

The [init.lua](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/init.lua) is loaded when `nvim` is opened. 
It loads configurations from the following files

- [base.lua](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/lua/base.lua) for basic settings
- [maps.lua](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/lua/maps.lua) for key mappings
- [hightlights.lua](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/lua/maps.lua) for highlighting
- [plugins.lua](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/lua/plugins.lua) for loading plugins

All settings to plugins are located either in [:file_folder: /plugin](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/lua/plugin) or [:file_folder: /after/plugin](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/lua/after/plugin).

## :electric_plug: Plugins

I use [packer](https://github.com/wbthomason/packer.nvim) as a plugin manager for nvim. Install using:

```shell
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

I use the following plugins (that are loaded in this [file](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/lua/plugins.lua)):

- [nvim-web-devicons](https://github.com/nvim-lualine/lualine.nvim) for dev icons
- [lualine](https://github.com/nvim-lualine/lualine.nvim) for a status line
- [nvim-bufferline]()
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip) for snippets
- [treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [prettier](https://github.com/MunifTanjim/prettier.nvim)
- [null-ls]()
- [nvim-autopairs](https://github.com/windwp/nvim-autopairs)
- [nvim-ts-autotag](https://github.com/windwp/nvim-autopairs)
- [plenary](https://github.com/nvim-lua/plenary.nvim) because telescope needs it
- [telescope](https://github.com/nvim-telescope/telescope.nvim) for file fuzzy finding
- [telescope-filebrowser](https://github.com/nvim-telescope/telescope-file-browser.nvim) for file browsing

LSP-Settings
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [lspkind-nvim](https://github.com/onsails/lspkind.nvim) for small pictograms in lsp
- [cmp-buffer](https://github.com/hrsh7th/cmp-buffer) for buffer words
- [cmp-nvim-lsp]()
- [nvim-cmp]()
- [lspsaga]()

To run the language servers, you initially need to download the servers:
For a full list of all available langauge servers, see [this page](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)

```
npm i -g tssserver typescriptserver
npm i -g pyright
```

Treesitter needs to install custom language servers to provide extended syntax highlighting and indentation. Install with the command from inside `nvim`:

```
:TSInstall python javascript typescript
```
