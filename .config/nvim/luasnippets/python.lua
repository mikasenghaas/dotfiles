-- python lua snippets

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local boil = s("boil", {
  t({
    "from sys.stdin import readline, readlines",
    "from collections import defaultdict, Counter",
    "",
    "def main():",
    "    "
  }),
  i(0),
  t({
    "",
    "",
    "if __name__ == '__main__':",
    "    main()"
  })
})

return { boil }
