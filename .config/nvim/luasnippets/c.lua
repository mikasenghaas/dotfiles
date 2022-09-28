-- c lua snippets

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local boil = s("boil", {
  t({ "#include <stdio.h>", "#include <stdlib.h>", "", "int main() {" }),
  i(0),
  t({ "", "  return 0;", "}" })
})

return { boil }
