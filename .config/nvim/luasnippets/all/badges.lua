-- custom global lua snippets

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local prettier = s("badge_prettier", {
  t("[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square)](https://github.com/prettier/prettier)"),
})

local last_commit = s("badge_last_commit", {
  t("https://img.shields.io/github/last-commit/"),
  i(1),
  t("/"),
  i(0),
  t("?style=flat-square")
})

local contributors = s("badge_contributers", {
  t("https://img.shields.io/github/contributors/"),
  i(1),
  t("/"),
  i(0),
  t("?style=flat-square")
})

return { prettier, last_commit, contributors }
