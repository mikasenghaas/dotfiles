-- plugins.lua
--  packer.nvim for plugin managment
-- by: mika senghaas

local status, packer = pcall(require, 'packer')
if (not status) then
  print("packer is not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'
  use {
    'svrana/neosolarized.nvim',
    requires = { 'tjdevries/colorbuddy.nvim' }
  }
  use 'kyazdani42/nvim-web-devicons' -- file icons
  use 'L3MON4D3/LuaSnip' -- snippets
  use 'hoob3rt/lualine.nvim' -- statusline
  use 'onsails/lspkind-nvim' -- vscode-like pictograms
  use 'hrsh7th/cmp-buffer' -- nvim-cmp source for buffer words
  use 'hrsh7th/cmp-nvim-lsp' -- nvim-cmp source for neovim built-in lsp
  use 'hrsh7th/nvim-cmp' -- completion
  use 'neovim/nvim-lspconfig' -- lsp
  use 'glepnir/lspsaga.nvim' -- lsp saga extension for lsp
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'jose-elias-alvarez/null-ls.nvim' -- use nvim as language server for prettier
  use 'MunifTanjim/prettier.nvim' -- prettier for nvim

  use 'windwp/nvim-autopairs' -- auto pairs
  use 'windwp/nvim-ts-autotag' -- auto tag
  use 'nvim-lua/plenary.nvim' -- dependency for telescope
  use 'nvim-telescope/telescope.nvim' -- fuzzy find
  use 'nvim-telescope/telescope-file-browser.nvim' -- fuzzy find

  use 'akinsho/nvim-bufferline.lua' -- custom buffer line
end)
