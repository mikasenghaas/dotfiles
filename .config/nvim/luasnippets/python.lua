-- custom global lua snippets

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- open template file
local lines = {}
local file = "~/.config/nvim/luasnippets/template.py"
if file_exists(file) then
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
end

local template = s("template", {
  t(lines)
})

return { template }
