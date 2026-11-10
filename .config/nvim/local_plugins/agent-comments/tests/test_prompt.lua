local prompt = require("agent-comments.prompt")

-- A comment stores the block prompt.item renders, so a message is built from seeded items exactly
-- as init.comment_range seeds them.
local function seeded(c, snippet, max)
	return {
		comment = {
			text = table.concat(prompt.item(c, snippet, max), "\n"),
			modified = c.modified,
		},
	}
end

T.test("prompt: a whole-file item is the bare path and a blank, with no quote", function()
	T.eq(
		prompt.item(
			{ file = "/tmp/x.py", start_line = 1, end_line = 1, whole_file = true },
			{ "ignored" }
		),
		{ "/tmp/x.py", "" }
	)
	T.eq(
		prompt.item({
			file = "/tmp/x.py",
			start_line = 1,
			end_line = 1,
			whole_file = true,
			modified = true,
		}),
		{ "/tmp/x.py [unsaved]", "" }
	)
end)

T.test("prompt: single comment renders as path, range, quoted line, comment", function()
	local s = prompt.format({
		seeded({
			file = "/tmp/x.py",
			start_line = 5,
			end_line = 5,
			text = "rename to double",
		}, { "def f(x): return x*2" }),
	})
	local expected = table.concat({
		"1 comment:",
		"",
		"/tmp/x.py:5-5",
		"   5 | def f(x): return x*2",
		"",
		"rename to double",
	}, "\n")
	T.eq(s, expected)
	T.ok(not s:find("End of comments", 1, true), "no footer terminates the message")
	T.ok(s:sub(-1) ~= "\n", "the message ends with the last comment line, not a blank line")
end)

T.test("prompt: the header counts the items and pluralises", function()
	local one = prompt.format({
		seeded({ file = "a.lua", start_line = 1, end_line = 1, text = "c1" }, { "a" }),
	})
	T.ok(one:find("1 comment:", 1, true) == 1)

	local two = prompt.format({
		seeded({ file = "a.lua", start_line = 1, end_line = 1, text = "c1" }, { "a" }),
		seeded({ file = "b.lua", start_line = 1, end_line = 1, text = "c2" }, { "b" }),
	})
	T.ok(two:find("2 comments:", 1, true) == 1)
end)

T.test("prompt: multiple comments, whole snippet quoted", function()
	local s = prompt.format({
		seeded(
			{ file = "a.rs", start_line = 1, end_line = 5, text = "c1" },
			{ "l1", "l2", "l3", "l4", "l5" }
		),
		seeded({ file = "b.rs", start_line = 2, end_line = 3, text = "c2" }, { "x", "y" }),
	})
	T.ok(s:find("2 comments:", 1, true) == 1)
	T.ok(s:find("\na.rs:1-5\n", 1, true), "the header ends at the range, with no parenthetical")
	T.ok(s:find("\n   3 | l3\n", 1, true))
	T.ok(s:find("\n   5 | l5\n", 1, true), "the whole snippet must be quoted, not capped at 3")
	T.ok(not s:find("omitted", 1, true), "an uncapped snippet must not claim omissions")
	T.ok(s:find("\nb.rs:2-3\n", 1, true), "the header ends at the range, with no parenthetical")
	T.ok(s:find("\n\nc2", 1, true))
end)

T.test("prompt: a capped snippet names the omitted count and true end line", function()
	local s = prompt.format({
		seeded(
			{ file = "big.lua", start_line = 10, end_line = 14, text = "too long" },
			{ "a", "b", "c", "d", "e" },
			2
		),
	})
	T.ok(s:find("\n   10 | a\n   11 | b\n", 1, true), "the cap's worth of lines is quoted")
	T.ok(not s:find("| c", 1, true), "lines past the cap are not quoted")
	T.ok(
		s:find(
			"\n   ... 3 more line(s) omitted, through line 14; read the file for the rest\n",
			1,
			true
		),
		"truncation is announced with the count and the true end line"
	)
end)

T.test("prompt: quoted line numbers count up from start_line", function()
	local s = prompt.format({
		seeded({ file = "m.lua", start_line = 100, end_line = 101, text = "note" }, { "x", "y" }),
	})
	T.ok(s:find("\n   100 | x\n   101 | y\n", 1, true))
	T.ok(not s:find("   1 | x", 1, true), "numbering must not restart at 1")
end)

T.test("prompt: line numbers stay right-aligned when their width grows mid-item", function()
	local s = prompt.format({
		seeded(
			{ file = "w.lua", start_line = 9, end_line = 11, text = "widths" },
			{ "nine", "", "eleven" }
		),
	})
	T.ok(s:find("\n    9 | nine\n   10 |\n   11 | eleven\n", 1, true))
end)

T.test("prompt: unsaved items are marked and explained, saved-only items are not", function()
	local unsaved = prompt.format({
		seeded({
			file = "u.lua",
			start_line = 1,
			end_line = 1,
			text = "wip",
			modified = true,
		}, { "draft" }),
	})
	T.ok(unsaved:find("\nu.lua:1-1 [unsaved]", 1, true), "a modified comment is marked")
	T.ok(unsaved:find("Items marked [unsaved] quote my editor buffer", 1, true))

	local saved = prompt.format({
		seeded({ file = "s.lua", start_line = 1, end_line = 1, text = "ok" }, { "final" }),
	})
	T.ok(not saved:find("[unsaved]", 1, true), "an unmodified comment is not marked")
	T.ok(not saved:find("not yet written to disk", 1, true), "no preamble without unsaved items")
end)

T.test("prompt: an item is the header, the quoted code, a blank line, then the comment", function()
	local s = prompt.format({
		seeded(
			{ file = "a.lua", start_line = 3, end_line = 3, text = "tighten this" },
			{ "local x = 1" }
		),
	})
	T.ok(s:find("\na.lua:3-3\n   3 | local x = 1\n\ntighten this", 1, true))
	T.ok(not s:find("1. ", 1, true), "items carry no number")
	T.ok(not s:find("Comment:", 1, true), "the comment text carries no label")
end)

T.test("prompt: a blank line inside a comment carries no trailing whitespace", function()
	local s = prompt.format({
		seeded({ file = "b.lua", start_line = 1, end_line = 1, text = "one\n\ntwo" }, { "x" }),
	})
	T.ok(s:find("\none\n\ntwo", 1, true))
	T.ok(not s:find(" \n", 1, true), "no rendered line ends in a space")
end)

T.test("prompt: an item with empty text ends in exactly one blank line", function()
	local lines = prompt.item({ file = "e.lua", start_line = 1, end_line = 1, text = "" }, { "x" })
	T.eq(lines, { "e.lua:1-1", "   1 | x", "" })
	T.ok(lines[#lines] == "" and lines[#lines - 1] ~= "", "exactly one blank line ends the item")
end)

T.test("prompt: an item is emitted byte for byte", function()
	local body = table.concat({
		"v.lua:1-2",
		"   1 | alpha",
		"   the annotation belongs between these two lines",
		"   2 | beta",
		"",
		"   9. and this numbering survives",
	}, "\n")
	local s = prompt.format({ { comment = { text = body } } })
	T.eq(s, "1 comment:\n\n" .. body)
end)

T.test("prompt: a seeded item round-trips into the message unchanged", function()
	local c = { file = "r.lua", start_line = 7, end_line = 8, text = "line one\n\n2. line two" }
	local item = table.concat(prompt.item(c, { "alpha", "beta" }), "\n")
	T.eq(prompt.format({ { comment = { text = item } } }), "1 comment:\n\n" .. item)
end)
