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
  -- specials
  use 'mfussenegger/nvim-jdtls' -- configure java language server

  -- styling
  use { 'svrana/neosolarized.nvim', requires = { 'tjdevries/colorbuddy.nvim' } }
  use 'kyazdani42/nvim-web-devicons' -- file icons
  use { 'akinsho/bufferline.nvim', tag = "v2.5.1" } -- tab/bufferline
  use 'hoob3rt/lualine.nvim' -- statusline
  use 'L3MON4D3/LuaSnip' -- snippets

  use 'hrsh7th/cmp-buffer' -- nvim-cmp source for buffer words
  use 'hrsh7th/cmp-nvim-lsp' -- nvim-cmp source for neovim built-in lsp

  -- depedencies
  use 'nvim-lua/plenary.nvim' -- dependency for several plugins

  -- suggestions, auto-complete, linter, formatter
  use 'williamboman/mason.nvim' -- ui for installing language servers
  use 'williamboman/mason-lspconfig.nvim' -- bridges mason with lspconfig
  use 'neovim/nvim-lspconfig' -- neovim lsp (language server protocol)

  use 'glepnir/lspsaga.nvim' -- code actions, error detection
  use 'onsails/lspkind-nvim' -- vscode-like pictograms

  -- auto-complete
  use 'hrsh7th/nvim-cmp' -- completion engine

  -- formatter
  use 'jose-elias-alvarez/null-ls.nvim' -- use nvim as language server for prettier
  use 'MunifTanjim/prettier.nvim' -- prettier for nvim
  use 'windwp/nvim-autopairs' -- auto pairs
  use 'windwp/nvim-ts-autotag' -- auto tag

  -- fuzzy find
  use 'nvim-telescope/telescope.nvim' -- fuzzy find
  use 'nvim-telescope/telescope-file-browser.nvim' -- fuzzy find

  -- highlighting
  use 'norcalli/nvim-colorizer.lua' -- show colors
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }


end)
