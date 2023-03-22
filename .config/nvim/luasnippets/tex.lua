-- python lua snippets

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- condition checking if cursor in math
local in_math = function()
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

-- TODO: tab completion for snippets, but not for all completions?
-- TODO: maybe still tab, but then something else to jump places in the snippet

-- return table of snippets
return {
  -- greek letters
  s( { trig=";a", dscr="Expand Greek \\alpha", snippetType="autosnippet" }, { t("\\alpha ") }),
  s( { trig=";b", dscr="Expand Greek \\beta", snippetType="autosnippet" }, { t("\\beta ")  }),
  s( { trig=";g", dscr="Expand Greek \\gamma", snippetType="autosnippet" }, { t("\\gamma ") }),
  s( { trig=";d", dscr="Expand Greek \\delta", snippetType="autosnippet" }, { t("\\delta ") }),
  s( { trig=";e", dscr="Expand Greek \\epsilon", snippetType="autosnippet" }, { t("\\epsilon ") }),
  s( { trig=";t", dscr="Expand Greek \\theta", snippetType="autosnippet" }, { t("\\theta ") }),
  s( { trig=";i", dscr="Expand Greek \\iota", snippetType="autosnippet" }, { t("\\iota ") }),
  s( { trig=";k", dscr="Expand Greek \\kappa", snippetType="autosnippet" }, { t("\\kappa ") }),
  s( { trig=";m", dscr="Expand Greek \\mu", snippetType="autosnippet" }, { t("\\mu ") }),
  s( { trig=";r", dscr="Expand Greek \\rho", snippetType="autosnippet" }, { t("\\rho ") }),
  s( { trig=";s", dscr="Expand Greek \\sigma", snippetType="autosnippet" }, { t("\\sigma ") }),
  s( { trig=";S", dscr="Expand Greek \\Sigma", snippetType="autosnippet" }, { t("\\Sigma ") }),
  s( { trig=";t", dscr="Expand Greek \\tau", snippetType="autosnippet" }, { t("\\tau ") }),
  s( { trig=";p", dscr="Expand Greek \\phi", snippetType="autosnippet" }, { t("\\phi ") }),
  s( { trig=";P", dscr="Expand Greek \\Phi", snippetType="autosnippet" }, { t("\\Phi ") }),
  s( { trig=";o", dscr="Expand Greek \\omega", snippetType="autosnippet" }, { t("\\omega ") }),
  s( { trig=";O", dscr="Expand Greek \\Omega", snippetType="autosnippet" }, { t("\\Omega ") }),


  -- environments
  s({ trig="env", dscr="Creates a New Environment", snippetType="autosnippet" },
    fmta(
      [[
        \begin{<>}
            <>
        \end{<>}
      ]],
      { i(1), i(0), rep(1) }
    )
  ),

  s({ trig = "ali", dscr = "Align Environment", snippetType="autosnippet" },
    fmta(
      [[
        \begin{align*}
          <>
        \end{align*}
      ]],
    { i(1) }
    )
  ),
  s({ trig = "case", name = "Cases", snippetType="autosnippet" },
    fmta(
      [[
        \begin{cases}
          <>
        \end{cases}
      ]],
    { i(1) }
    ),
    {condition = in_math}
  ),
  s({trig="([^%a])mm", dscr="Inline Math", snippetType="autosnippet", wordTrig = false, regTrig = true},
    fmta(
      [[<>$<>$]],
      { f( function(_, snip) return snip.captures[1] end ), i(1) }
    )
  ),
  s({trig="([^%a])dm", name="Display Math", snippetType="autosnippet", wordTrig=false, regTrig=true },
    fmta(
      [[
      <>\[<>\]
      ]],
      { f( function(_, snip) return snip.captures[1] end ), i(1) }
    ),
    {condition = in_math}
  ),
  s({trig="dm", dscr="Display Math", snippetType="autosnippet", wordTrig = false, regTrig = true},
    fmta(
      [[
        \[
          <>
        \]
      ]],
      { i(1) }
    )
  ),

  -- superscript/subscript
  s({trig="([%a%d%)%]%}])sr", name="^2", snippetType="autosnippet", wordTrig=false, regTrig=true },
    fmta(
      "<>^2",
      { f( function(_, snip) return snip.captures[1] end ) }
    ),
    {condition = in_math}
  ),
  s({trig="([%a%d%)%]%}])cb", name="^3", snippetType="autosnippet", wordTrig=false, regTrig=true },
    fmta(
      "<>^3",
      { f( function(_, snip) return snip.captures[1] end ) }
    ),
    {condition = in_math}
  ),
  s({trig="([%a%d%)%]%}])^^", name="Superscript", snippetType="autosnippet", wordTrig=false, regTrig=true },
    fmta(
      "<>^{<>}",
      { f( function(_, snip) return snip.captures[1] end ), i(1)}
    ),
    {condition = in_math}
  ),
  s({trig="([%a%d%)%]%}])__", name="Subscript", snippetType="autosnippet", wordTrig=false, regTrig=true },
    fmta(
      "<>_{<>}",
      { f( function(_, snip) return snip.captures[1] end ), i(1)}
    ),
    {condition = in_math}
  ),
  s({trig="([%a%d%)%]%}])invs", name="Inverse", snippetType="autosnippet", wordTrig=false, regTrig=true },
    fmta(
      "<>^{-1}",
      { f( function(_, snip) return snip.captures[1] end )}
    ),
    {condition = in_math}
  ),

  -- fractions
  s({trig="//", name="Fraction", snippetType="autosnippet", priority=100},
    fmta(
      "\\frac{<>}{<>}",
      { i(1), i(2) }
    ),
    {condition = in_math}
  ),

  s({trig="([%d])/", name="Fraction", snippetType="autosnippet", wordTrig=false, regTrig=true },
    fmta(
      "\\frac{<>}{<>}",
      { f( function(_, snip) return snip.captures[1] end ), i(1) }
    ),
    {condition = in_math}
  ),

  -- postfixes
  s({trig="([%a])bar", dscr="Insert Bar Command with letter before 'bar'", snippetType="autosnippet", wordTrig=false, regTrig=true, priority=100}, 
    fmta( 
      "\\bar{<>}", 
      { f( function(_, snip) return snip.captures[1] end )}
    ),
    {condition = in_math}
  ),

  s({trig="bar", dscr="Insert Bar Command", snippetType="autosnippet", priority=10}, 
    fmta( 
      "\\bar{<>}", { i(1) }), 
    {condition = in_math}
  ),

  s({trig="([%a])hat", dscr="Insert hat Command with letter before 'bar'", snippetType="autosnippet", wordTrig=false, regTrig=true, priority=100}, 
    fmta( 
      "\\hat{<>}", 
      { f( function(_, snip) return snip.captures[1] end ) }
    ), 
    {condition = in_math}
  ),

  s({trig="hat", dscr="Insert Hat Command", snippetType="autosnippet", priority=10}, 
    fmta( 
      "\\hat{<>}", 
      { i(1) }
    ), 
    {condition = in_math}
  ),

  s({trig="([%a])vec", dscr="Insert Vector with previous letter", snippetType="autosnippet", wordTrig=false, regTrig=true, priority=100}, 
    fmta( 
      "\\vec{<>}", 
      { f( function(_, snip) return snip.captures[1] end ) }
    ), 
    {condition = in_math}
  ),
  s({trig="vec", dscr="Insert Vector", snippetType="autosnippet", priority=10}, 
    fmta( 
      "\\vec{<>}", 
      { i(1) }
    ), 
    {condition = in_math}
  ),


  -- misc
  s({trig="fun", dscr="Function from R to R", snippetType="autosnippet"},
    fmta(
      "f: \\R \\to \\R: ", {}
    ), 
    { condition = in_math }),

  s({trig="lim", dscr="Limit Expression", snippetType="autosnippet"}, 
    fmta(
      "lim_{<>} ",
      { i(1, [[n \to \infty]])}
    ),
    { condition = in_math }
  ),
  s({trig="int", dscr="Integral Expression", snippetType="autosnippet"}, 
    fmta(
      "\\int_{<>}^{<>}",
      { i(1, [[-\infty]]), i(2, [[\infty]])}
    ),
    { condition = in_math }
  ),
  s({trig="sum", dscr="Sum Expression", snippetType="autosnippet"}, 
    fmta(
      "\\sum_{<>}^{<>}",
      { i(1, "i"), i(2, "")}
    ),
    { condition = in_math }
  ),
  s({trig="prod", dscr="Product Expression", snippetType="autosnippet"}, 
    fmta(
      "\\prod{<>}^{<>}",
      { i(1, "i"), i(2, "")}
    ),
    { condition = in_math }
  ),

  -- letters
  s({trig="HH", dscr="H Symbol", snippetType="autosnippet"}, 
    fmta([[\mathbb{H}]], {}),
    { condition = in_math }
  ),
  s({trig="DD", dscr="D Symbol", snippetType="autosnippet"}, 
    fmta([[\mathbb{D}]], {}),
    { condition = in_math }
  ),
  s({trig="RR", dscr="R Symbol", snippetType="autosnippet"}, 
    fmta([[\R]], {}),
    { condition = in_math }
  ),
  s({trig="ZZ", dscr="Z Symbol", snippetType="autosnippet"}, 
    fmta([[\Z]], {}),
    { condition = in_math }
  ),
  s({trig="QQ", dscr="Q Symbol", snippetType="autosnippet"}, 
    fmta([[\Q]], {}),
    { condition = in_math }
  ),
  s({trig="NN", dscr="N Symbol", snippetType="autosnippet"}, 
    fmta([[\NN]], {}),
    { condition = in_math }
  ),
  s({trig="OO", dscr="O Symbol", snippetType="autosnippet"}, 
    fmta([[\OO]], {}),
    { condition = in_math }
  ),

  -- commmon variables
  s({trig="xii", dscr="x_i", snippetType="autosnippet"}, 
    fmta([[x_i]], {}),
    { condition = in_math }
  ),
  s({trig="yii", dscr="y_i", snippetType="autosnippet"}, 
    fmta([[y_i]], {}),
    { condition = in_math }
  ),
  s({trig="xjj", dscr="x_j", snippetType="autosnippet"}, 
    fmta([[x_j]], {}),
    { condition = in_math }
  ),
  s({trig="yjj", dscr="y_j", snippetType="autosnippet"}, 
    fmta([[y_j]], {}),
    { condition = in_math }
  ),
  s({trig="xn", dscr="x_n", snippetType="autosnippet"}, 
    fmta([[x_n]], {}),
    { condition = in_math }
  ),
  s({trig="yn", dscr="y_n", snippetType="autosnippet"}, 
    fmta([[y_n]], {}),
    { condition = in_math }
  ),

  -- misc symbols
  s( { trig="ooo", dscr="Expand Infinity Symbol", snippetType="autosnippet" }, 
    fmta( [[\infty]], {}), 
    { condition=in_math }
  ),
  s( { trig="nabl", dscr="Expand Nabla Symbol", snippetType="autosnippet" }, 
    fmta( [[\nabla]], {}), 
    { condition=in_math }
  ),
  s( { trig="iinn", dscr="Expand In Symbol", snippetType="autosnippet" }, 
    fmta( [[\in]], {}), 
    { condition=in_math }
  ),
  s( { trig="notin", dscr="Expand Not In Symbol", snippetType="autosnippet" }, 
    fmta( [[\not\in]], {}), 
    { condition=in_math }
  ),
  s( { trig="cc", dscr="Expand Subset Symbol", snippetType="autosnippet" }, 
    fmta( [[\subset]], {}), 
    { condition=in_math }
  ),
  s( { trig="xx", dscr="Expand Times Symbol", snippetType="autosnippet" }, 
    fmta( [[\times]], {}), 
    { condition=in_math }
  ),
  s( { trig="**", dscr="Expand Dot Symbol", snippetType="autosnippet" }, 
    fmta( [[\cdot]], {}), 
    { condition=in_math }
  ),
  s( { trig="part", dscr="Partial", snippetType="autosnippet" }, 
    fmta(
      [[\frac{\partial <>}{\partial <>}]], 
      { i(1, ""), i(2, "x")}), 
    { condition=in_math }
  ),
  s( { trig="sq", dscr="Square Root", snippetType="autosnippet" }, 
    fmta( [[\sqrt{<>}]], { i(1) }), 
    { condition=in_math }
  ),

  -- fontstyle
  s({trig="tt", dscr="Expands 'tt' into '\texttt{}'"}, { t("\\texttt{"), i(1), t("}"), }),
  s({trig="bo", dscr="Expands 'tt' into '\textbf{}'"}, { t("\\textbf{"), i(1), t("}"), }),
  s({trig="it", dscr="Expands 'tt' into '\textit}'"}, { t("\\textit{"), i(1), t("}"), }),

  -- hyperref
  s({trig="href", dscr="The hyperref package's href{}{} command (for url links)"},
    fmta(
      [[\href{<>}{<>}]],
      { i(1, "url"), i(2, "display name"), }
    )
  ),
}
