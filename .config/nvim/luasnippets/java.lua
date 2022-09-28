-- java lua snippets

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local boil = s("boil", {
  t({
    "import java.util.*;",
    "",
    "public class ",
  }),
  i(1),
  t({
    " {",
    "  public static void main(String[] args) {",
    "    Scanner sc = new Scanner(System.in);",
    "    ",
    "    ",
  }),
  i(2),
  t({
    "",
    "  }",
    "}",
  }),
})

return { boil }
