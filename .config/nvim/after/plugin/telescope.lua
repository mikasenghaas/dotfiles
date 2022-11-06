-- telescope.lua
--  configs for telescope (nvim fuzzy finder)
-- by: Mika Senghaas

local status, telescope = pcall(require, "telescope")
if (not status) then return end

local builtin = require('telescope.builtin')

telescope.setup {
  defaults = {
    prompt_prefix = '🔍 ',
    selection_caret = '▶️ ',
    multi_icon = '✳️',
    defaults = {
      scroll_strategy = 'limit',
    }
  },
  pickers = {
    find_files = {
      no_ignore = false,
      hidden = true
    }, 
    git_files = {
      theme = 'dropdown',
      no_ignore = false,
      hidden = true
    }
  },
}

-- fuzzy find files
vim.keymap.set('n', 'ff', function() builtin.find_files() end)

-- fuzzy find through git files
vim.keymap.set('n', 'gf', function() 
  local git_dir = vim.fn.finddir('.git', vim.fn.getcwd() .. ";")
  if git_dir ~= "" then
    builtin.git_files() 
  else
    local cwd = vim.fn.getcwd()
    print("Not a git repository (" .. cwd .. ")")
  end
end)
