-- copilo.lua
--  configs for github copilot
-- by: Mika Senghaas

-- use <Tab> for completion
vim.g.copilot_assume_mapped = true
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

vim.g.copilot_filetypes = {
  ["*"] = false,
  ["markdown"] = true,
  ["tex"] = true,
  ["javascript"] = true,
  ["typescript"] = true,
  ["rust"] = true,
  ["c"] = true,
  ["c#"] = true,
  ["c++"] = true,
  ["go"] = true,
  ["python"] = true,
}
