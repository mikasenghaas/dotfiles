-- plugins.lua
--  neovim plugins
-- by: mika senghaas

local status, packer = pcall(require, 'packer')
if (not status) then
  print("packer is not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'

  -- styling
  use 'kyazdani42/nvim-web-devicons'
  use 'folke/tokyonight.nvim'
  use 'hoob3rt/lualine.nvim'
  use 'akinsho/bufferline.nvim'

  -- autopairs/ tags
  use 'windwp/nvim-autopairs'
  use 'windwp/nvim-ts-autotag'

  -- completion engine
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-emoji'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'saadparwaiz1/cmp_luasnip'

  -- snippet engine (linked to completion engine)
  use 'L3MON4D3/LuaSnip'
  use 'rafamadriz/friendly-snippets'

  -- fuzzy finding
  use {
    'nvim-telescope/telescope.nvim', 
     requires = { 'nvim-lua/plenary.nvim' }
  }

  -- language server
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'onsails/lspkind.nvim'
  use 'glepnir/lspsaga.nvim'
  use 'jose-elias-alvarez/null-ls.nvim'

  -- astro
  use 'wuelnerdotexe/vim-astro'

  -- fsharp
  use 'ionide/Ionide-vim'

  -- tex
  use 'lervag/vimtex'

  -- copilot
  use 'github/copilot.vim'

  -- treesitter (buffer parsing)
  use {
    'nvim-treesitter/nvim-treesitter', 
    run = ':TSUpdate'
  }
end)
