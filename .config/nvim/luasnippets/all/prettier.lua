-- custom global lua snippets

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local fmt = require("luasnip.extras.fmt").fmt
local extras = require("luasnip.extras")
local m = extras.m
local l = extras.l
local rep = extras.rep
local postfix = require("luasnip.extras.postfix").postfix

local prettier_js = {
  "const options = {",
  "  arrowParens: 'avoid'",
  "  singleQuote: true",
  "  bracketSpacing: true",
  "  endOfLine: 'lf'",
  "  semi: false",
  "  tabWidth: 2",
  "  trailingComma: 'none'",
  "}",
  "",
  "module.export = options;",
}

local prettier = s("prettier", t(prettier_js))

return { prettier }
