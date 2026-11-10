local ui = require("agent-comments.ui")
local comments = require("agent-comments.comments")

local function scratch_named(lines, name)
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)
	if name then
		vim.api.nvim_buf_set_name(b, name)
	end
	return b
end

T.test("ui: visual_range normalizes reversed marks", function()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "a", "b", "c", "d" })
	vim.api.nvim_set_current_buf(b)
	vim.api.nvim_buf_set_mark(b, "<", 3, 0, {})
	vim.api.nvim_buf_set_mark(b, ">", 1, 0, {})
	local s, e = ui.visual_range()
	T.eq({ s, e }, { 1, 3 })
end)

T.test(
	"ui: decorate rails each line in the sign column + a callout, undecorate removes both",
	function()
		comments.clear()
		local b = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(b, 0, -1, false, { "x", "y", "z" })
		local id = comments.add(b, 1, 2, "needs work here truly") -- 2-line block
		ui.decorate(id)
		local marks = vim.api.nvim_buf_get_extmarks(b, ui.ns, 0, -1, { details = true })
		local bars, tinted, callout = 0, 0, nil
		for _, m in ipairs(marks) do
			if m[4].sign_text then
				bars = bars + 1
			end
			if m[4].line_hl_group then
				tinted = tinted + 1
			end
			if m[4].virt_lines then
				callout = m
			end
		end
		T.eq(bars, 2, "one sign-column rail cell per annotated line")
		T.eq(tinted, 2, "one background tint per annotated line")
		T.ok(callout, "expected a callout virt_lines extmark")
		-- The rail must NOT be inline virt_text: that shifts the annotated code
		-- sideways and knocks the block out of alignment with the rest of the file.
		for _, m in ipairs(marks) do
			T.ok(not m[4].virt_text, "rail lives in the sign column, not inline")
		end
		T.eq(callout[2], 0, "callout anchors above the FIRST line, not below the last")
		ui.undecorate(id)
		marks = vim.api.nvim_buf_get_extmarks(b, ui.ns, 0, -1, { details = true })
		T.eq(#marks, 0, "undecorate removes the rail, the tint and the callout")
	end
)

T.test("ui: decorations do not land in the range-tracking namespace", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "x", "y", "z" })
	local id = comments.add(b, 1, 2, "two lines")
	ui.decorate(id)
	T.eq(
		#vim.api.nvim_buf_get_extmarks(b, comments.ns, 0, -1, {}),
		1,
		"one tracking extmark per comment, whatever it is decorated with"
	)
	T.eq(#vim.api.nvim_buf_get_extmarks(b, ui.ns, 0, -1, {}), 3, "two rail cells plus one callout")
end)

T.test("ui: one-line decoration marks a single line", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "x", "y" })
	local id = comments.add(b, 1, 1, "single")
	ui.decorate(id)
	local marks = vim.api.nvim_buf_get_extmarks(b, ui.ns, 0, -1, { details = true })
	local bars = 0
	for _, m in ipairs(marks) do
		if m[4].sign_text then
			bars = bars + 1
		end
	end
	T.eq(bars, 1)
end)

T.test("ui: the callout for a multi-line comment stays a single line", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "x", "y" })
	local id = comments.add(b, 1, 1, "why is this here\nand why now")
	ui.decorate(id)
	local virt_lines
	for _, m in ipairs(vim.api.nvim_buf_get_extmarks(b, ui.ns, 0, -1, { details = true })) do
		virt_lines = virt_lines or m[4].virt_lines
	end
	T.ok(virt_lines, "expected a callout virt_lines extmark")
	T.eq(#virt_lines, 1, "the callout occupies one virtual line")
	for _, chunk in ipairs(virt_lines[1]) do
		T.ok(not chunk[1]:find("\n", 1, true), "no callout chunk may contain a newline")
	end
	T.ok(
		virt_lines[1][#virt_lines[1]][1]:find("2 lines", 1, true) ~= nil,
		"the callout counts the lines of the block"
	)
	ui.undecorate(id)
	comments.clear()
end)

T.test("ui: a whole-file comment gets a callout and no rail", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "x", "y" })
	local id = comments.add(b, 1, 1, "/f.py\n\nwhy", { whole_file = true })
	ui.decorate(id)
	local bars, callouts = 0, 0
	for _, m in ipairs(vim.api.nvim_buf_get_extmarks(b, ui.ns, 0, -1, { details = true })) do
		if m[4].sign_text then
			bars = bars + 1
		end
		if m[4].virt_lines then
			callouts = callouts + 1
		end
	end
	T.eq({ bars, callouts }, { 0, 1 })
	ui.undecorate(id)
	comments.clear()
end)

T.test("ui: comment row format", function()
	T.eq(
		ui.comment_row({
			file = "/a/b/mod.rs",
			start_line = 3,
			end_line = 9,
			text = "one\ntwo\nthree",
		}),
		"mod.rs:3-9  3 lines"
	)
	T.eq(
		ui.comment_row({ file = "/a/b/mod.rs", start_line = 3, end_line = 3, text = "one" }),
		"mod.rs:3-3  1 line"
	)
	T.eq(
		ui.comment_row({
			file = "/a/b/mod.rs",
			start_line = 1,
			end_line = 1,
			text = "one\ntwo",
			whole_file = true,
		}),
		"mod.rs  2 lines"
	)
end)

T.test("ui: summary of a missing or empty text is empty", function()
	T.eq(ui.summary({}), "")
	T.eq(ui.summary({ text = "" }), "")
end)

local function list_keymap(buf, lhs)
	for _, m in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
		if m.lhs == lhs then
			return m.callback
		end
	end
end

-- A code window parked deep inside a long buffer, plus a second buffer to hang the comment on,
-- so a preview has to both swap the buffer and lose the saved scroll position.
local function scrolled_code_win(tag)
	local long = {}
	for i = 1, 200 do
		long[i] = "line " .. i
	end
	local origin_buf = scratch_named(long, "/tmp/hn-ui-origin-" .. tag .. ".lua")
	local target_buf = scratch_named({ "x", "y", "z" }, "/tmp/hn-ui-target-" .. tag .. ".lua")
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, origin_buf)
	vim.api.nvim_win_set_cursor(win, { 150, 0 })
	vim.api.nvim_win_call(win, function()
		vim.cmd("normal! zz")
	end)
	return win, origin_buf, target_buf
end

T.test("ui: comment_list renders one line per comment", function()
	comments.clear()
	local b1 = scratch_named({ "x" }, "/tmp/hn-ui-a.lua")
	local b2 = scratch_named({ "y" }, "/tmp/hn-ui-b.lua")
	comments.add(b1, 1, 1, "first")
	comments.add(b2, 1, 1, "second")
	ui.comment_list({ edit = function() end, delete = function() end })
	local list_buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(list_buf, 0, -1, false)
	T.eq(lines, {
		ui.comment_row(comments.list()[1]),
		ui.comment_row(comments.list()[2]),
	})
	vim.api.nvim_win_close(0, true)
end)

T.test("ui: a multi-line comment renders as one row counting its lines", function()
	comments.clear()
	local b = scratch_named({ "x" }, "/tmp/hn-ui-multiline.lua")
	comments.add(b, 1, 1, "tidy this up\nand rename it\nthen move it")
	ui.comment_list({ edit = function() end, delete = function() end })
	local list_buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(list_buf, 0, -1, false)
	T.eq(lines, { "hn-ui-multiline.lua:1-1  3 lines" })
	list_keymap(list_buf, "q")()
	comments.clear()
end)

T.test("ui: deleting the last comment closes the window", function()
	comments.clear()
	local b = scratch_named({ "x" }, "/tmp/hn-ui-c.lua")
	local id = comments.add(b, 1, 1, "only")
	ui.comment_list({
		edit = function() end,
		delete = function(c)
			comments.delete(c.id)
		end,
	})
	local win = vim.api.nvim_get_current_win()
	local list_buf = vim.api.nvim_get_current_buf()
	T.ok(comments.get(id) ~= nil)
	local del = list_keymap(list_buf, "dd")
	T.ok(del ~= nil, "expected a 'dd' keymap in the comment list")
	del()
	T.eq(comments.get(id), nil)
	T.ok(not vim.api.nvim_win_is_valid(win), "window should close once no comments remain")
end)

T.test("ui: editing a comment refreshes its row", function()
	comments.clear()
	local b = scratch_named({ "x" }, "/tmp/hn-ui-d.lua")
	comments.add(b, 1, 1, "before")
	ui.comment_list({
		edit = function(c, refresh)
			comments.edit(c.id, "after\nand more")
			refresh()
		end,
		delete = function() end,
	})
	local list_buf = vim.api.nvim_get_current_buf()
	local edit = list_keymap(list_buf, "e")
	T.ok(edit ~= nil, "expected an 'e' keymap in the comment list")
	edit()
	T.eq(vim.api.nvim_buf_get_lines(list_buf, 0, -1, false), { "hn-ui-d.lua:1-1  2 lines" })
	vim.api.nvim_win_close(0, true)
end)

T.test("ui: cancelling the list restores the code window's buffer and view", function()
	comments.clear()
	local code_win, origin_buf, target_buf = scrolled_code_win("cancel")
	comments.add(target_buf, 2, 2, "in another buffer")
	local before = vim.api.nvim_win_call(code_win, vim.fn.winsaveview)
	T.ok(before.topline > 1, "setup must leave the origin window scrolled off the first line")

	ui.comment_list({ edit = function() end, delete = function() end })
	local list_buf = vim.api.nvim_get_current_buf()
	T.eq(vim.api.nvim_win_get_buf(code_win), target_buf, "previewing moves the code window")

	list_keymap(list_buf, "q")()
	T.eq(vim.api.nvim_win_get_buf(code_win), origin_buf, "cancelling puts the buffer back")
	local after = vim.api.nvim_win_call(code_win, vim.fn.winsaveview)
	T.eq(after.lnum, before.lnum, "cancelling puts the cursor back")
	T.eq(after.topline, before.topline, "cancelling puts the scroll position back")
end)

T.test("ui: <CR> keeps the previewed position", function()
	comments.clear()
	local code_win, _, target_buf = scrolled_code_win("jump")
	comments.add(target_buf, 2, 2, "in another buffer")

	ui.comment_list({ edit = function() end, delete = function() end })
	local list_win = vim.api.nvim_get_current_win()
	local list_buf = vim.api.nvim_get_current_buf()

	list_keymap(list_buf, "<CR>")()
	T.ok(not vim.api.nvim_win_is_valid(list_win), "<CR> dismisses the list")
	T.eq(vim.api.nvim_win_get_buf(code_win), target_buf, "<CR> leaves the code window previewed")
	T.eq(vim.api.nvim_win_get_cursor(code_win)[1], 2, "<CR> leaves the cursor on the comment")
end)

T.test("ui: a bare d does not delete", function()
	comments.clear()
	local b = scratch_named({ "x" }, "/tmp/hn-ui-bare-d.lua")
	local id = comments.add(b, 1, 1, "survivor")
	ui.comment_list({
		edit = function() end,
		delete = function(c)
			comments.delete(c.id)
		end,
	})
	local list_buf = vim.api.nvim_get_current_buf()
	T.eq(list_keymap(list_buf, "d"), nil, "a bare d must not be bound")
	T.ok(list_keymap(list_buf, "dd") ~= nil, "dd is the delete gesture")
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.api.nvim_feedkeys("d" .. esc, "x", false)
	T.ok(comments.get(id) ~= nil, "a stray d leaves the comment alone")
	list_keymap(list_buf, "q")()
end)

local function open_list_floats()
	local n = 0
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		local wb = vim.api.nvim_win_get_buf(w)
		if
			vim.api.nvim_win_get_config(w).relative ~= ""
			and vim.bo[wb].filetype == "agent-comments"
		then
			n = n + 1
		end
	end
	return n
end

T.test("ui: opening the list twice leaves only the newer window", function()
	comments.clear()
	local b = scratch_named({ "x" }, "/tmp/hn-ui-reopen.lua")
	comments.add(b, 1, 1, "only")
	ui.comment_list({ edit = function() end, delete = function() end })
	local first = vim.api.nvim_get_current_win()
	ui.comment_list({ edit = function() end, delete = function() end })
	local second = vim.api.nvim_get_current_win()
	T.ok(not vim.api.nvim_win_is_valid(first), "the first list window must not survive")
	T.ok(second ~= first and vim.api.nvim_win_is_valid(second), "the second list window is open")
	T.eq(open_list_floats(), 1, "exactly one comment list float at a time")
	list_keymap(vim.api.nvim_get_current_buf(), "q")()
end)

T.test("ui: refresh_list without an open list does nothing", function()
	comments.clear()
	local b = scratch_named({ "x" }, "/tmp/hn-ui-refresh.lua")
	comments.add(b, 1, 1, "transient")
	ui.comment_list({ edit = function() end, delete = function() end })
	list_keymap(vim.api.nvim_get_current_buf(), "q")()
	T.ok(pcall(ui.refresh_list), "refresh_list must not error once the list is closed")
	T.eq(open_list_floats(), 0, "refresh_list does not resurrect a closed list")
end)

T.test("ui: highlights survive a colorscheme change", function()
	-- The suite shares one nvim instance, so put the colourscheme back before asserting.
	local previous = vim.g.colors_name or "default"
	vim.cmd.colorscheme("blue")
	local sign = vim.api.nvim_get_hl(0, { name = "AgentCommentsSign" })
	pcall(vim.cmd.colorscheme, previous)
	T.ok(sign.fg ~= nil, "AgentCommentsSign keeps its colour after a :colorscheme")
end)

T.test("ui: navigating out of the list cancels it", function()
	comments.clear()
	local code_win, origin_buf, target_buf = scrolled_code_win("winleave")
	comments.add(target_buf, 2, 2, "in another buffer")
	local before = vim.api.nvim_win_call(code_win, vim.fn.winsaveview)
	T.ok(before.topline > 1, "setup must leave the origin window scrolled off the first line")

	ui.comment_list({ edit = function() end, delete = function() end })
	local list_win = vim.api.nvim_get_current_win()
	T.eq(vim.api.nvim_win_get_buf(code_win), target_buf, "previewing moves the code window")

	vim.api.nvim_set_current_win(code_win)
	vim.wait(2000, function()
		return not vim.api.nvim_win_is_valid(list_win)
	end)
	T.ok(not vim.api.nvim_win_is_valid(list_win), "leaving the list window closes it")
	T.eq(vim.api.nvim_win_get_buf(code_win), origin_buf, "leaving puts the buffer back")
	local after = vim.api.nvim_win_call(code_win, vim.fn.winsaveview)
	T.eq(after.lnum, before.lnum, "leaving puts the cursor back")
	T.eq(after.topline, before.topline, "leaving puts the scroll position back")
end)

T.test("ui: the WinLeave cancel does not undo a <CR> jump", function()
	comments.clear()
	local code_win, _, target_buf = scrolled_code_win("winleave-jump")
	comments.add(target_buf, 2, 2, "in another buffer")

	ui.comment_list({ edit = function() end, delete = function() end })
	local list_buf = vim.api.nvim_get_current_buf()
	list_keymap(list_buf, "<CR>")()
	-- Closing the float fires WinLeave too, so give the deferred cancel its chance to run before
	-- asserting that the jump survived it.
	vim.wait(200, function()
		return false
	end)
	T.eq(vim.api.nvim_win_get_buf(code_win), target_buf, "<CR> leaves the code window previewed")
	T.eq(vim.api.nvim_win_get_cursor(code_win)[1], 2, "<CR> leaves the cursor on the comment")
end)

local function open_editor_floats()
	local n = 0
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		local wb = vim.api.nvim_win_get_buf(w)
		if
			vim.api.nvim_win_get_config(w).relative ~= ""
			and vim.api.nvim_buf_get_name(wb):match("^agent%-comment://")
		then
			n = n + 1
		end
	end
	return n
end

local function quit_editor(buf)
	vim.api.nvim_buf_call(buf, function()
		vim.cmd("quit")
	end)
end

T.test("ui: :w commits the editor buffer joined by newlines", function()
	local done, got = false, nil
	ui.input_comment(function(text)
		done, got = true, text
	end)
	local ebuf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(ebuf, 0, -1, false, { "  leading space kept", "", "third" })
	vim.api.nvim_buf_call(ebuf, function()
		vim.cmd("write")
	end)
	vim.wait(2000, function()
		return done
	end)
	T.ok(done, "on_done must fire after a :w")
	T.eq(got, "  leading space kept\n\nthird", ":w commits the buffer raw, blank lines and all")
	T.eq(open_editor_floats(), 0, "the editor float is gone once it has committed")
end)

T.test("ui: the editor is markdown but keeps its own textwidth and folds", function()
	local grp = vim.api.nvim_create_augroup("AgentCommentsTestMarkdown", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = grp,
		pattern = "markdown",
		callback = function()
			vim.opt_local.textwidth = 100
		end,
	})
	local origin_win = vim.api.nvim_get_current_win()
	vim.wo[origin_win].foldenable = true
	local done = false
	ui.input_comment(function()
		done = true
	end)
	local ebuf = vim.api.nvim_get_current_buf()
	local ewin = vim.api.nvim_get_current_win()
	vim.api.nvim_del_augroup_by_id(grp)
	vim.wo[origin_win].foldenable = false
	T.eq(vim.bo[ebuf].filetype, "markdown")
	T.eq(vim.bo[ebuf].textwidth, 0, "a markdown FileType hook must not hard-wrap the comment")
	T.eq(vim.wo[ewin].foldenable, false, "folds inherited from the code window stay off")
	quit_editor(ebuf)
	vim.wait(2000, function()
		return done
	end)
	T.eq(open_editor_floats(), 0)
end)

T.test("ui: :q cancels the editor and reports nil", function()
	local done, got = false, "never called"
	ui.input_comment(function(text)
		done, got = true, text
	end)
	local ebuf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(ebuf, 0, -1, false, { "typed then abandoned" })
	T.eq(list_keymap(ebuf, "q"), nil, "q must not be bound: it would discard the text by reflex")
	T.eq(list_keymap(ebuf, "<Esc>"), nil, "<Esc> is the insert-to-normal key, not a cancel")
	for _, mode in ipairs({ "n", "i" }) do
		T.ok(
			vim.tbl_isempty(vim.fn.maparg("<C-c>", mode, false, true)),
			"<C-c> must not be bound: it is the habitual way out of insert mode"
		)
	end
	quit_editor(ebuf)
	vim.wait(2000, function()
		return done
	end)
	T.ok(done, "on_done must fire on a cancel as well as a commit")
	T.eq(got, nil, "a cancel reports nil, not the discarded text")
	T.eq(open_editor_floats(), 0)
end)

T.test("ui: :q on a modified editor cancels instead of raising E37", function()
	local done, got = false, "never called"
	ui.input_comment(function(text)
		done, got = true, text
	end)
	local ebuf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(ebuf, 0, -1, false, { "abandoned" })
	T.ok(vim.bo[ebuf].modified, "the editor must be modified for this to mean anything")
	local ok, err = pcall(vim.cmd, "quit")
	T.ok(ok, "expected :q to close the editor, got " .. tostring(err))
	vim.wait(2000, function()
		return done
	end)
	T.ok(done, "on_done must fire after a :q")
	T.eq(got, nil, ":q discards the text")
	T.eq(open_editor_floats(), 0)
end)

T.test("ui: :wq closes the editor window and no other", function()
	vim.cmd("split")
	local before = #vim.api.nvim_list_wins()
	local done, got = false, nil
	ui.input_comment(function(text)
		done, got = true, text
	end)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "ship it" })
	vim.cmd("wq")
	vim.wait(2000, function()
		return done
	end)
	T.ok(done, "on_done must fire after a :wq")
	T.eq(got, "ship it")
	T.eq(#vim.api.nvim_list_wins(), before, ":wq must take down the editor and nothing else")
	T.eq(open_editor_floats(), 0)
	vim.cmd("only")
end)

T.test("ui: a seeded editor holds its lines with the cursor on the last", function()
	local done, got = false, nil
	ui.input_comment(function(text)
		done, got = true, text
	end, { lines = { "one", "two", "three" } })
	local ewin, ebuf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
	T.eq(vim.api.nvim_buf_get_lines(ebuf, 0, -1, false), { "one", "two", "three" })
	T.eq(vim.api.nvim_win_get_cursor(ewin)[1], 3, "the cursor starts on the last seeded line")
	T.ok(not vim.bo[ebuf].modified, "a freshly seeded editor is unmodified, so :q is a clean exit")
	vim.api.nvim_buf_call(ebuf, function()
		vim.cmd("write")
	end)
	vim.wait(2000, function()
		return done
	end)
	T.ok(done)
	T.eq(got, "one\ntwo\nthree", "an untouched seed round-trips unchanged")
	T.eq(open_editor_floats(), 0)
end)

T.test("ui: closing the editor returns focus to the window it was opened from", function()
	vim.cmd("split")
	local from = vim.api.nvim_get_current_win()
	local other
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if w ~= from and vim.api.nvim_win_get_config(w).relative == "" then
			other = w
		end
	end
	local done = false
	ui.input_comment(function()
		done = true
	end)
	local ebuf = vim.api.nvim_get_current_buf()
	-- Committing from somewhere else: without the restore, focus would simply stay here.
	vim.api.nvim_set_current_win(other)
	vim.api.nvim_buf_call(ebuf, function()
		vim.cmd("write")
	end)
	vim.wait(2000, function()
		return done
	end)
	T.ok(done)
	T.eq(vim.api.nvim_get_current_win(), from, "focus goes back to where the editor was opened")
	T.eq(open_editor_floats(), 0)
	vim.cmd("only")
end)

T.test("ui: a second editor opened on top of the first gets its own buffer name", function()
	local done1, done2 = false, false
	ui.input_comment(function()
		done1 = true
	end)
	local first = vim.api.nvim_get_current_buf()
	ui.input_comment(function()
		done2 = true
	end)
	local second = vim.api.nvim_get_current_buf()
	T.ok(first ~= second, "each editor gets its own buffer")
	T.ok(
		vim.api.nvim_buf_get_name(first) ~= vim.api.nvim_buf_get_name(second),
		"a name reused while the first buffer lives fails the open with E95"
	)
	T.eq(open_editor_floats(), 2, "both editors are open at once")
	quit_editor(second)
	vim.wait(2000, function()
		return done2
	end)
	quit_editor(first)
	vim.wait(2000, function()
		return done1
	end)
	T.ok(done1 and done2, "each editor reports its own exit")
	T.eq(open_editor_floats(), 0)
end)

T.test("ui: an open editor float is not counted as a comment list", function()
	local done = false
	ui.input_comment(function()
		done = true
	end)
	T.eq(open_list_floats(), 0, "an editor float must not read as a comment list")
	T.eq(open_editor_floats(), 1)
	quit_editor(vim.api.nvim_get_current_buf())
	vim.wait(2000, function()
		return done
	end)
	T.ok(done)
	T.eq(open_editor_floats(), 0)
end)

T.test("ui: opening the editor from the list does not cancel the list", function()
	comments.clear()
	local b = scratch_named({ "x" }, "/tmp/hn-ui-list-editor.lua")
	comments.add(b, 1, 1, "before")
	local refreshed = false
	ui.comment_list({
		edit = function(c, refresh)
			ui.input_comment(function(text)
				if text then
					comments.edit(c.id, text)
				end
				refresh()
				refreshed = true
			end, { lines = vim.split(c.text, "\n", { plain = true }) })
		end,
		delete = function() end,
	})
	local list_win = vim.api.nvim_get_current_win()
	local list_buf = vim.api.nvim_get_current_buf()

	list_keymap(list_buf, "e")()
	local ebuf = vim.api.nvim_get_current_buf()
	T.ok(vim.api.nvim_buf_get_name(ebuf):match("^agent%-comment://"), "`e` opens a comment editor")
	-- The list cancels itself on WinLeave, which entering the editor just fired.
	vim.wait(300, function()
		return false
	end)
	T.ok(vim.api.nvim_win_is_valid(list_win), "the list survives the editor opening on top of it")

	vim.api.nvim_buf_set_lines(ebuf, 0, -1, false, { "after", "and more" })
	vim.api.nvim_buf_call(ebuf, function()
		vim.cmd("write")
	end)
	vim.wait(2000, function()
		return refreshed
	end)
	T.ok(refreshed, "committing the editor runs the list's refresh callback")
	T.ok(
		vim.api.nvim_buf_get_lines(list_buf, 0, -1, false)[1]:find("2 lines", 1, true) ~= nil,
		"the row counts the lines the editor committed"
	)
	T.eq(open_editor_floats(), 0)
	T.eq(open_list_floats(), 1, "the list is still the only list float")
	list_keymap(list_buf, "q")()
	comments.clear()
end)

T.test("ui: a draft gets the rail alone, with no empty callout bubble", function()
	comments.clear()
	local b = scratch_named({ "x", "y", "z" })
	local id = comments.add(b, 1, 2, nil)
	ui.decorate(id)
	local marks = vim.api.nvim_buf_get_extmarks(b, ui.ns, 0, -1, { details = true })
	local bars, callouts = 0, 0
	for _, m in ipairs(marks) do
		if m[4].sign_text then
			bars = bars + 1
		end
		if m[4].virt_lines then
			callouts = callouts + 1
		end
	end
	T.eq(bars, 2, "the rail marks the lines the open editor is anchored to")
	T.eq(callouts, 0, "a draft has nothing to say, so it says nothing")
	ui.undecorate(id)
	T.eq(vim.api.nvim_buf_get_extmarks(b, ui.ns, 0, -1, {}), {}, "undecorate clears a draft too")
end)
