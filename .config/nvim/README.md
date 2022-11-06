# neovim

[`neovim`](https://neovim.io/) is the next-generation vim. 

Neovim is installed (with Python support) from the `Brewfile` and is configured using `lua`. The overall design goal 
of these neovim settings was simplicity. I want to use as little plugins as possible (or at least have as little as possible)
enabled by default and want to diverge as little as possible from Neovim's or a plugin's default settings.

**Every divergance from the default is chosen with deliberately.**

## :file_folder: Organisation

The [init.lua](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/init.lua) is loaded when `nvim` is opened. 
It loads configurations from the following files

- [base.lua](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/lua/base.lua) for basic settings
- [maps.lua](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/lua/maps.lua) for key mappings
- [plugins.lua](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/lua/plugins.lua) for specifying plugins

*Note, that the `base` and `maps` configurations are equivalent to the vimlang settings in the regular [vim setup](https://github.com/mikasenghaas/dotfiles/tree/main/.vim)*

## :electric_plug: Plugins

I use [packer](https://github.com/wbthomason/packer.nvim) as a plugin manager for nvim. 
Plugin managers - as the name suggests - help you install, update and delete neovim plugins written by other people. 

First, packer needs to be installed on your machine. On Linux/ Unix system install by running

```shell
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

For other platforms, please visit [packer's docs](https://github.com/wbthomason/packer.nvim). Once installed, you should be able to run the following vim command without any errors.

```vimscript
:lua require('packer'):
```

Essentially, packer gives you access to a handful of useful plugins, of which these two I use regularly:

1. `PackerInstall` to install all plugins listed in `require('packer').startup(...)` (for me located [here](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim/lua/mikasenghaas/plugins.lua))
2. `PackerUpdate` to update all plugins listed in `require('packer').startup(...)` (*Make sure to periodically run this command to keep your plugins up to date*)

If you just installed my dotfiles and packer, then run `PackerInstall` to load all plugins I specified in `lua/mikasenghaas/plugin.lua` onto your local machine (on `macOS` the system's default directory is ` ~/.local/share/nvim/site/pack/packer/start/packer.nvim`).
🛫 Your plugins are now loaded and my settings should apply automatically.

In the following section I will walk through all plugins and relevant keymaps in categories.

### 🎨 Styling 

I style neovim using the following four plugins:

```lua
use 'kyazdani42/nvim-web-devicons'
use 'folke/tokyonight.nvim'
use 'hoob3rt/lualine.nvim'
use 'akinsho/bufferline.nvim'
```

[`nvim-web-devicons`]() is a plugin that inserts nice icons both in the bufferline and statusline. I did not further configure this plugin.
[`tokyonight`]() is the colorscheme that I use in my terminal as well as in neovim. It has support from both `lualine` and`bufferline` and serves my purposes. I enabled italic comments and a transparent background, because it works nicely with my terminal setup, but you might want to change that.
[`lualine`]() is a lightweight statusline (bottom line), which shows meta information about the current buffer. It has strong defaults and adapts to the colorscheme by default, so I did not alter the configurations at all. 
[`bufferline`]() is a lightweight bufferline (showing open buffers) which integrates both with tokyonight and the web-devicons easily. I had to make some small adjustments to its styling to make it perfect for me.


### {} Autopairs/ -tags

Autopairs and autotags are two useful plugins that two exactly what you would expect them to do. I did not further configure them.

```lua
use 'windwp/nvim-autopairs'
use 'windwp/nvim-ts-autotag'
```

### 💡 Completion Engine

A powerful completion engine is what people often miss most when trying to make the change from modern IDEs or editors to neovim. 
Let's look at all the plugins involving the completion engine 

```
use 'hrsh7th/nvim-cmp'
use 'hrsh7th/cmp-buffer'
use 'hrsh7th/cmp-path'
use 'hrsh7th/cmp-emoji'
use 'hrsh7th/cmp-cmdline'
use 'saadparwaiz1/cmp_luasnip'
use 'hrsh7th/cmp-nvim-lsp'
```

At the base of the configurations is the plugin `nvim-cmp`, which is the wrapper providing fast completion popups. 
To make it functional, however, it needs completion sources. There is a dozen completion sources out there (listed [here](https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources)), 
but the ones I use and have configured are:

1. `nvim-buffer` to autocomplete words in the current buffer
2. `nvim-path` to autocomplete paths in the file system
3. `nvim-emoji` to autocomplete emojis after typing `:`
4. `nvim-cmdline` to autcomplete vim commands
5. `cmp_luasnip` to autocomplete snippets (*more on this in a bit*)
6. `cmp-nvim-lsp` to autocomplete snippets (*see section LSP*)

All the additional completion sources do not require any additional setup. After having installed them with packer, just add them to `sources` in the `cmp.setup` call (I have done this already for all completion sources mentioned above).

**⌨️ Keymaps**

While typing in insert mode, you should now get completion suggestions. Let's look at the key mappings to interact with these:

1. `<Tab>`: Cycle forward in the list of suggestions
2. `<Shift-Tab>`: Cycle backward in the list of suggestions
3. `<Esc>`: Escape completion popup
3. `<Enter>`: Autocomplete completion suggestion under current cursor

You can toggle Cmp by running either `:CmpStart` or `:CmpStop` in the current buffer. By default completion is enabled.


### 💬 LSP (Language Server Protocol)

To really make neovim powerful, you would expect autosuggestions for packages you use in any language, as well as in-line diagnostics and code improvements.
All such functionality is provided by language servers (and editors like VSCode come more or less preinstalled with these for all kinds of programming languages).
Neovim also provides a default experience, which is is configured in a series of plugins.

```
use 'neovim/nvim-lspconfig'
use 'williamboman/mason.nvim'
use 'williamboman/mason-lspconfig.nvim'
use 'onsails/lspkind.nvim'
use 'glepnir/lspsaga.nvim'
```

All settings are located in `after/plugin/lsp.lua`. `lspconfig` is also integrated with `nvim-cmp` in order to get completion for language server features.

1. `nvim-lspconfig` is the base of the configuration, which provides a nice API to configure the neovim LSP experience
2. `mason` is a language server manager, which is convenient to use to install language servers.
3. `mason-lspconfig` is necessary to integrate mason with nvim-lspconfig. This integration is already done in the settings.
4. `lspkind` puts nice icons into the completion source for lsp items
5. `lspsaga` provides performant, easy-to-use LSP features, such as renaming, go to/ peek defintion, code actions and more

You can toggle LSP by running either `:LspStart` or `:LspStop` in the current buffer. By default LSP is enabled for all language except Python and C.

### 🗺️ File Navigation

Lastly, we need a quick way to jump between files and buffers. This functinality is provided by `telescope`, which depends on the `plenary` plugin.

```
use {
  'nvim-telescope/telescope.nvim', 
   requires = { 'nvim-lua/plenary.nvim' }
}
```
  
Telescope is a fuzzy-finder plugin. I use it only to fuzzy find in between files further down in the project tree (starts from directory neovim was opened in):

1. `ff` in normal mode: Open telescope dialogue to fuzzy find over all files (respecting .gitignore) from root directory
2. `gf` in normal mode: Open telscope dialogue to fuzzy find over all git files from root directory (must be called from within a local git repository)

By default the popup starts in insert mode, so you can immediately start typing. The following (default keymaps) are good-to-know:

1. `<C-n>/<Down>`: Next item
2. `<C-p>/<Up>`: Previous item
3. `j/k`: Next/ previos (in normal mode)
4. `<Enter>`: Confirm selection (open in current buffer)
5. `<C-x>`: Open file in horizontal split
6. `<C-v>`: Open file in vertical split
7. `<C-t>`: Open file in a new tab (I do this quite a lot)
8. `<C-u>`: Scoll up in preview window
9. `<C-d>`: Scoll down in preview window
10. `<C-c>`: Close telescope
