local hn = require("agent-comments")
local comments = require("agent-comments.comments")

T.test("init: comment_line adds a decorated comment via stubbed input", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local orig = ui.input_comment
	ui.input_comment = function(cb)
		cb("stub comment")
	end
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "one", "two" })
	vim.api.nvim_set_current_buf(b)
	vim.api.nvim_win_set_cursor(0, { 2, 0 })
	hn.comment_line()
	ui.input_comment = orig
	local l = comments.list()
	T.eq(#l, 1)
	T.eq({ l[1].start_line, l[1].text }, { 2, "stub comment" })
end)

T.test("init: comment_file seeds the bare path and stores a whole-file comment", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local orig = ui.input_comment
	local seed
	ui.input_comment = function(cb, opts)
		seed = opts.lines
		cb(table.concat(seed, "\n") .. "about the whole file")
	end
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "one", "two", "three" })
	vim.api.nvim_buf_set_name(b, "/tmp/agent-comments-whole-file.py")
	vim.api.nvim_set_current_buf(b)
	vim.api.nvim_win_set_cursor(0, { 3, 0 })
	local path = vim.api.nvim_buf_get_name(b)
	hn.comment_file()
	ui.input_comment = orig
	T.eq(seed, { path, "", "" })
	local l = comments.list()
	T.eq(#l, 1)
	T.eq({ l[1].whole_file, l[1].text }, { true, path .. "\n\nabout the whole file" })
	T.eq(comments.snippet(l[1].id), {})
	comments.clear()
	vim.api.nvim_buf_delete(b, { force = true })
end)

T.test("init: comment_selection uses the visual marks", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local orig = ui.input_comment
	ui.input_comment = function(cb)
		cb("stub sel")
	end
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "a", "b", "c", "d" })
	vim.api.nvim_set_current_buf(b)
	vim.api.nvim_buf_set_mark(b, "<", 2, 0, {})
	vim.api.nvim_buf_set_mark(b, ">", 4, 0, {})
	hn.comment_selection()
	ui.input_comment = orig
	local list = comments.list()
	T.eq({ list[1].start_line, list[1].end_line }, { 2, 4 })
end)

T.test("init: comment_selection normalizes reversed marks", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local orig = ui.input_comment
	ui.input_comment = function(cb)
		cb("stub sel")
	end
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "a", "b", "c", "d" })
	vim.api.nvim_set_current_buf(b)
	vim.api.nvim_buf_set_mark(b, "<", 4, 0, {})
	vim.api.nvim_buf_set_mark(b, ">", 2, 0, {})
	hn.comment_selection()
	ui.input_comment = orig
	local list = comments.list()
	T.eq({ list[1].start_line, list[1].end_line }, { 2, 4 })
end)

T.test("init: edit_comment updates text and refreshes its callout", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	local id = comments.add(b, 1, 1, "old text")
	ui.decorate(id)
	local c = comments.get(id)

	local orig = ui.input_comment
	ui.input_comment = function(cb)
		cb("new text\nand more")
	end
	hn.edit_comment(c)
	ui.input_comment = orig

	T.eq(comments.get(id).text, "new text\nand more")
	local marks = vim.api.nvim_buf_get_extmarks(b, ui.ns, 0, -1, { details = true })
	local callout_text
	for _, mark in ipairs(marks) do
		if mark[4].virt_lines then
			callout_text = mark[4].virt_lines[1][2][1]
		end
	end
	T.ok(callout_text and callout_text:find("2 lines", 1, true), "callout counts the edited text")
end)

T.test("init: send_all formats, dispatches, clears", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-send.lua")
	vim.api.nvim_set_current_buf(b)

	local ui = require("agent-comments.ui")
	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local sent = {}
	local o1, o2, o3 = ui.pick_agent, dispatch.send, agents.list
	ui.pick_agent = function(_, cb)
		cb({ pane_id = "wZ:p9", title = "π", status = "idle" })
	end
	dispatch.send = function(pane, text, opts)
		sent = { pane, text, opts }
		return true
	end
	agents.list = function()
		return { { pane_id = "wZ:p9", title = "π", status = "idle" } }
	end

	local o4 = ui.input_comment
	ui.input_comment = function(cb, opts)
		cb(table.concat(opts.lines, "\n") .. "check this")
	end
	hn.comment_range(1, 1)
	ui.input_comment = o4

	hn.send_all({ submit = false })
	ui.pick_agent, dispatch.send, agents.list = o1, o2, o3

	T.eq(sent[1], "wZ:p9")
	T.ok(sent[2]:find("\n" .. vim.api.nvim_buf_get_name(b) .. ":1-1", 1, true))
	T.ok(sent[2]:find("   1 | alpha", 1, true))
	T.eq(sent[3].submit, false)
	T.eq(comments.list(), {}, "clear_after_send default clears comments")
end)

T.test("init: a send that clears the comments closes an open comment list", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha", "beta" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-send-list-open.lua")
	comments.add(b, 1, 1, "check this")
	comments.add(b, 2, 2, "and this")

	ui.comment_list({ edit = function() end, delete = function() end })
	local list_win = vim.api.nvim_get_current_win()
	T.ok(vim.api.nvim_win_is_valid(list_win), "the list must be open before the send")

	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local o1, o2, o3 = ui.pick_agent, dispatch.send, agents.list
	ui.pick_agent = function(_, cb)
		cb({ pane_id = "wZ:p9", title = "pi", status = "idle" })
	end
	dispatch.send = function()
		return true
	end
	agents.list = function()
		return { { pane_id = "wZ:p9", title = "pi", status = "idle" } }
	end

	hn.send_all({ submit = false })
	ui.pick_agent, dispatch.send, agents.list = o1, o2, o3

	T.eq(comments.list(), {}, "the send clears the comment store")
	T.ok(not vim.api.nvim_win_is_valid(list_win), "the list must not outlive the comments it shows")
end)

T.test("init: with clear_after_send off a send leaves the list open and populated", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-send-list-kept.lua")
	comments.add(b, 1, 1, "keep me")

	ui.comment_list({ edit = function() end, delete = function() end })
	local list_win = vim.api.nvim_get_current_win()
	local list_buf = vim.api.nvim_get_current_buf()

	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local o1, o2, o3 = ui.pick_agent, dispatch.send, agents.list
	local previous_clear = hn.config.clear_after_send
	hn.config.clear_after_send = false
	ui.pick_agent = function(_, cb)
		cb({ pane_id = "wZ:p9", title = "pi", status = "idle" })
	end
	dispatch.send = function()
		return true
	end
	agents.list = function()
		return { { pane_id = "wZ:p9", title = "pi", status = "idle" } }
	end

	hn.send_all({ submit = false })
	ui.pick_agent, dispatch.send, agents.list = o1, o2, o3
	hn.config.clear_after_send = previous_clear

	T.eq(#comments.list(), 1, "clear_after_send off keeps the comments")
	T.ok(vim.api.nvim_win_is_valid(list_win), "the list stays open when nothing was cleared")
	T.eq(
		vim.api.nvim_buf_get_lines(list_buf, 0, -1, false),
		{ ui.comment_row(comments.list()[1]) },
		"the list still shows the surviving comment"
	)
	vim.api.nvim_win_close(list_win, true)
end)

T.test("init: send_all warns once when the resolved agent is working", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-send-working.lua")
	comments.add(b, 1, 1, "check this")

	local ui = require("agent-comments.ui")
	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local warns = {}
	local o1, o2, o3, on = ui.pick_agent, dispatch.send, agents.list, vim.notify
	ui.pick_agent = function()
		error("picker must not open for a lone agent")
	end
	dispatch.send = function()
		return true
	end
	agents.list = function()
		return {
			{
				pane_id = "wZ:p9",
				tab_id = "wZ:t1",
				kind = "pi",
				title = "pi",
				status = "working",
				cwd = "/x/y/z",
			},
		}
	end
	local notes = 0
	vim.notify = function(msg, level)
		notes = notes + 1
		if level == vim.log.levels.WARN then
			table.insert(warns, msg)
		end
	end

	hn.send_all({ submit = true })
	ui.pick_agent, dispatch.send, agents.list, vim.notify = o1, o2, o3, on

	T.eq(notes, 1, "a send must emit exactly one message")
	T.eq(#warns, 1, "working warning must fire exactly once")
	T.ok(warns[1]:find("working", 1, true), "warning names the working state")
	T.ok(warns[1]:find("sent 1 comment(s)", 1, true), "warning reports the send")
end)

T.test("init: send_all fits a long agent title on one line", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-send-long-title.lua")
	comments.add(b, 1, 1, "check this")

	local ui = require("agent-comments.ui")
	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local msgs = {}
	local o1, o2, o3, on = ui.pick_agent, dispatch.send, agents.list, vim.notify
	ui.pick_agent = function()
		error("picker must not open for a lone agent")
	end
	dispatch.send = function()
		return true
	end
	agents.list = function()
		return {
			{
				pane_id = "wZ:p9",
				tab_id = "wZ:t1",
				kind = "claude",
				title = "✳ " .. string.rep("long task summary ", 20),
				status = "idle",
				cwd = "/x/y/z",
			},
		}
	end
	vim.notify = function(msg)
		table.insert(msgs, msg)
	end

	hn.send_all({ submit = true })
	ui.pick_agent, dispatch.send, agents.list, vim.notify = o1, o2, o3, on

	T.eq(#msgs, 1, "a send must emit exactly one message")
	T.ok(vim.fn.strdisplaywidth(msgs[1]) < vim.v.echospace, "message must fit the command line")
	T.ok(
		vim.startswith(msgs[1], "agent-comments: sent 1 comment(s) to ✳"),
		"count survives the cut"
	)
end)

T.test("init: send_all shows the picker when agents are ambiguous", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-send-multi.lua")
	comments.add(b, 1, 1, "check this")

	local ui = require("agent-comments.ui")
	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local previous = vim.env.HERDR_TAB_ID
	vim.env.HERDR_TAB_ID = nil
	local picked, sent = false, {}
	local o1, o2, o3, o4 = ui.pick_agent, dispatch.send, agents.list, agents.resolve
	ui.pick_agent = function(l, cb)
		picked = true
		cb(l[1])
	end
	dispatch.send = function(pane)
		sent = { pane }
		return true
	end
	agents.list = function()
		return {
			{ pane_id = "wA:p1", tab_id = "wA:t1", title = "pi", status = "idle" },
			{ pane_id = "wB:p2", tab_id = "wB:t1", title = "claude", status = "idle" },
		}
	end
	-- Stubbed so an ambiguous list cannot reach a backend and query the real multiplexer.
	agents.resolve = function()
		return nil
	end

	hn.send_all({ submit = false })
	ui.pick_agent, dispatch.send, agents.list, agents.resolve = o1, o2, o3, o4
	vim.env.HERDR_TAB_ID = previous

	T.ok(picked, "picker must open when the target is ambiguous")
	T.eq(sent[1], "wA:p1")
end)

T.test("init: send_all skips the picker for a lone agent", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-send-solo.lua")
	comments.add(b, 1, 1, "check this")

	local ui = require("agent-comments.ui")
	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local picked, sent = false, {}
	local o1, o2, o3 = ui.pick_agent, dispatch.send, agents.list
	ui.pick_agent = function()
		picked = true
	end
	dispatch.send = function(pane)
		sent = { pane }
		return true
	end
	agents.list = function()
		return { { pane_id = "wZ:p9", tab_id = "wZ:t1", title = "pi", status = "idle" } }
	end

	hn.send_all({ submit = false })
	ui.pick_agent, dispatch.send, agents.list = o1, o2, o3

	T.ok(not picked, "picker must not open for a single unambiguous agent")
	T.eq(sent[1], "wZ:p9")
end)

T.test("init: send_all retains comments when dispatch.send fails", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-send-fail.lua")
	comments.add(b, 1, 1, "check this")

	local ui = require("agent-comments.ui")
	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local o1, o2, o3 = ui.pick_agent, dispatch.send, agents.list
	ui.pick_agent = function(_, cb)
		cb({ pane_id = "wZ:p9", title = "π", status = "idle" })
	end
	dispatch.send = function()
		return false, "boom"
	end
	agents.list = function()
		return { { pane_id = "wZ:p9", title = "π", status = "idle" } }
	end

	hn.send_all({ submit = false })
	ui.pick_agent, dispatch.send, agents.list = o1, o2, o3

	T.eq(#comments.list(), 1, "comments must be retained after a failed send")
end)

T.test("init: send_all reports a transport error and keeps the comment", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-send-no-session.lua")
	comments.add(b, 1, 1, "check this")

	local ui = require("agent-comments.ui")
	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local errors, sends = {}, 0
	local o1, o2, o3, on = ui.pick_agent, dispatch.send, agents.list, vim.notify
	ui.pick_agent = function()
		error("picker must not open without a transport")
	end
	dispatch.send = function()
		sends = sends + 1
		return true
	end
	agents.list = function()
		return nil, "not in a herdr session (HERDR_WORKSPACE_ID is unset)"
	end
	vim.notify = function(msg, level)
		if level == vim.log.levels.ERROR then
			table.insert(errors, msg)
		end
	end

	hn.send_all({ submit = false })
	ui.pick_agent, dispatch.send, agents.list, vim.notify = o1, o2, o3, on

	T.eq(#errors, 1, "transport error must be reported once")
	T.ok(errors[1]:find("herdr session", 1, true), "error surfaces the transport reason")
	T.eq(sends, 0, "dispatch.send must not run without a transport")
	T.eq(#comments.list(), 1, "comments must survive a transport error")
end)

T.test("init: send_all marks a comment whose buffer has unwritten changes", function()
	comments.clear()
	local b = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-send-unsaved.lua")
	vim.api.nvim_set_current_buf(b)

	local ui = require("agent-comments.ui")
	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local sent = {}
	local o1, o2, o3 = ui.pick_agent, dispatch.send, agents.list
	ui.pick_agent = function()
		error("picker must not open for a lone agent")
	end
	dispatch.send = function(_, text)
		sent = text
		return true
	end
	agents.list = function()
		return { { pane_id = "wZ:p9", title = "pi", status = "idle" } }
	end

	T.ok(vim.bo[b].modified, "a listed buffer is modified once lines are set")
	local o4 = ui.input_comment
	ui.input_comment = function(cb, opts)
		cb(table.concat(opts.lines, "\n") .. "check this")
	end
	hn.comment_range(1, 1)
	ui.input_comment = o4

	hn.send_all({ submit = false })
	ui.pick_agent, dispatch.send, agents.list = o1, o2, o3

	T.ok(sent:find("\n" .. vim.api.nvim_buf_get_name(b) .. ":1-1 [unsaved]", 1, true))
	T.ok(sent:find("Items marked [unsaved] quote my editor buffer", 1, true))
end)

T.test("init: comment_range anchors when the editor opens, not when it is written", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "one", "two", "three" })
	vim.api.nvim_set_current_buf(b)

	local orig = ui.input_comment
	ui.input_comment = function(cb)
		vim.api.nvim_buf_set_lines(b, 0, 0, false, { "inserted0", "inserted1" })
		cb("late")
	end
	hn.comment_range(2, 2)
	ui.input_comment = orig

	local l = comments.list()
	T.eq(#l, 1)
	T.eq({ l[1].start_line, l[1].end_line, l[1].text }, { 4, 4, "late" })
	T.eq(comments.snippet(l[1].id), { "two" }, "the comment quotes the line it was aimed at")
end)

T.test("init: cancelling the editor leaves no comment and no tracking extmark", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "one", "two" })
	vim.api.nvim_set_current_buf(b)

	local orig = ui.input_comment
	ui.input_comment = function(cb)
		cb(nil)
	end
	hn.comment_range(1, 2)
	ui.input_comment = orig

	T.eq(comments.list(), {}, "a cancelled draft is not a comment")
	T.eq(vim.api.nvim_buf_get_extmarks(b, comments.ns, 0, -1, {}), {}, "no range mark is left")
	T.eq(vim.api.nvim_buf_get_extmarks(b, ui.ns, 0, -1, {}), {}, "no rail is left on screen")
end)

T.test("init: a whitespace-only comment is a cancel", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "one", "two" })
	vim.api.nvim_set_current_buf(b)

	local orig = ui.input_comment
	ui.input_comment = function(cb)
		cb("  \n\t ")
	end
	hn.comment_range(1, 1)
	ui.input_comment = orig

	T.eq(comments.list(), {}, "whitespace is not a comment")
	T.eq(vim.api.nvim_buf_get_extmarks(b, comments.ns, 0, -1, {}), {}, "no range mark is left")
	T.eq(vim.api.nvim_buf_get_extmarks(b, ui.ns, 0, -1, {}), {}, "no rail is left on screen")
end)

T.test("init: a comment stores the rendered item it was seeded with", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha", "beta" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-seeded-store.lua")
	vim.api.nvim_set_current_buf(b)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })

	local seen
	local orig = ui.input_comment
	ui.input_comment = function(cb, opts)
		seen = opts
		cb(table.concat(opts.lines, "\n") .. "   my note")
	end
	hn.comment_line()
	ui.input_comment = orig

	T.eq(seen.lines[1], vim.api.nvim_buf_get_name(b) .. ":1-1", "the seed opens with the header")
	T.eq(seen.lines[2], "   1 | alpha")
	T.eq(
		comments.list()[1].text,
		vim.api.nvim_buf_get_name(b) .. ":1-1\n   1 | alpha\n\n   my note",
		"the block and the annotation typed into it are stored as one text"
	)
end)

T.test("init: a send quotes what was frozen, not what the buffer now holds", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local frozen = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(frozen, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(frozen, "/tmp/hn-frozen-send.lua")

	local orig = ui.input_comment
	ui.input_comment = function(cb, opts)
		cb(table.concat(opts.lines, "\n") .. "   frozen note")
	end
	vim.api.nvim_set_current_buf(frozen)
	hn.comment_range(1, 1)
	ui.input_comment = orig

	vim.api.nvim_buf_set_lines(frozen, 0, 1, false, { "MUTATED" })

	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local sent
	local o1, o2 = dispatch.send, agents.list
	dispatch.send = function(_, text)
		sent = text
		return true
	end
	agents.list = function()
		return { { pane_id = "wZ:p9", title = "pi", status = "idle" } }
	end
	hn.send_all({ submit = false })
	dispatch.send, agents.list = o1, o2

	local item = vim.api.nvim_buf_get_name(frozen) .. ":1-1\n   1 | "
	T.ok(sent:find(item .. "alpha", 1, true), "the frozen item quotes the line as it was")
	T.ok(not sent:find("MUTATED", 1, true), "an edit made under it cannot reach the message")
	T.ok(sent:find("   frozen note", 1, true), "the annotation typed into the block is sent")
end)

T.test("init: editing a comment reopens the block it stored", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-block-edit.lua")
	local id = comments.add(b, 1, 1, nil)
	local block = "/tmp/hn-block-edit.lua:1-1\n   1 | alpha\n\n   note"
	comments.edit(id, block)

	local seen
	local orig = ui.input_comment
	ui.input_comment = function(cb, opts)
		seen = opts
		cb(table.concat(opts.lines, "\n") .. " two")
	end
	hn.edit_comment(comments.get(id))
	ui.input_comment = orig

	T.eq(seen.lines, { "/tmp/hn-block-edit.lua:1-1", "   1 | alpha", "", "   note" })
	T.eq(comments.get(id).text, block .. " two")
end)

T.test("init: the seed is the rendered item plus the blank line the cursor starts on", function()
	comments.clear()
	local prompt = require("agent-comments.prompt")
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha", "beta" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-seed.lua")
	vim.api.nvim_set_current_buf(b)

	-- A stand-in over the same buffer and range: comment_range's own record is a draft, which
	-- comments.list() deliberately withholds while its editor is open.
	local ref = comments.add(b, 1, 2, "")
	local expected = prompt.item(comments.get(ref), comments.snippet(ref))
	expected[#expected + 1] = ""
	comments.delete(ref)

	hn.comment_range(1, 2)
	local ewin, ebuf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()

	T.eq(vim.api.nvim_buf_get_lines(ebuf, 0, -1, false), expected)
	T.eq(vim.api.nvim_win_get_cursor(ewin)[1], #expected, "the cursor starts on the extra line")
	T.eq(expected[#expected - 1], "", "the item's own blank line sits above the cursor")

	vim.api.nvim_win_close(ewin, true)
	vim.wait(2000, function()
		return #comments.list() == 0
	end)
	T.eq(#comments.list(), 0, "leaving the seed untouched cancels the draft")
end)

T.test("init: an annotation typed into a fresh seed is sent below a blank line", function()
	comments.clear()
	local ui = require("agent-comments.ui")
	local b = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(b, 0, -1, false, { "alpha" })
	vim.api.nvim_buf_set_name(b, "/tmp/hn-seed-typed.lua")
	vim.api.nvim_set_current_buf(b)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })

	local orig = ui.input_comment
	ui.input_comment = function(cb, opts)
		-- What typing on the cursor line does: it replaces the last seeded line.
		local typed = vim.list_extend({}, opts.lines)
		typed[#typed] = "hoist the multiplier into a parameter"
		cb(table.concat(typed, "\n"))
	end
	hn.comment_line()
	ui.input_comment = orig

	local dispatch = require("agent-comments.dispatch")
	local agents = require("agent-comments.agents")
	local sent
	local o1, o2 = dispatch.send, agents.list
	dispatch.send = function(_, text)
		sent = text
		return true
	end
	agents.list = function()
		return { { pane_id = "wZ:p3", title = "pi", status = "idle" } }
	end
	hn.send_all({ submit = false })
	dispatch.send, agents.list = o1, o2

	T.ok(
		sent:find("   1 | alpha\n\nhoist the multiplier into a parameter", 1, true) ~= nil,
		"a blank line separates the quoted code from the annotation"
	)
end)
