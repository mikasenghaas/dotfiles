local M = {}
local comments = require("agent-comments.comments")
local agents = require("agent-comments.agents")

-- Separate from comments.ns so a query means one thing: comments.ns holds exactly
-- one range-tracking extmark per comment, this one holds only drawing.
M.ns = vim.api.nvim_create_namespace("agent-comments-decorations")

-- An annotated block is drawn as three cooperating layers:
--   * a solid amber rail in the SIGN COLUMN, one cell per line of the block
--   * a subtle full-width background tint over those same lines
--   * a callout above the first line naming the comment
--
-- The rail lives in the sign column rather than as inline virt_text on purpose:
-- inline text shifts the annotated code sideways, so a block visibly jumps out
-- of alignment with the rest of the file the moment you comment on it.
--
-- The colour is a dedicated amber, NOT a link to DiagnosticWarn. Borrowing the
-- diagnostic colour makes comments compete with real warnings for the same
-- visual meaning. Override any of these highlights to retheme.
local function set_highlights()
	vim.api.nvim_set_hl(0, "AgentCommentsSign", { default = true, fg = "#d7a65f", bold = true })
	vim.api.nvim_set_hl(0, "AgentCommentsText", { default = true, fg = "#d7a65f" })
	-- Tint stays deliberately quiet -- the rail carries the colour. Linked to
	-- CursorLine so it tracks whatever the active colourscheme uses for "this
	-- region is active", on light and dark themes alike.
	vim.api.nvim_set_hl(0, "AgentCommentsLine", { default = true, link = "CursorLine" })
end

set_highlights()

-- A :colorscheme clears every highlight, so these have to be laid down again after one.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("AgentCommentsHighlights", { clear = true }),
	callback = set_highlights,
})

local decorations = {} -- comment id -> { hl, callout, bufnr }

-- There is only ever one comment list, tracked here so code outside comment_list()
-- (a send, say) can refresh or close it.
local open_list = nil

function M.visual_range()
	local s = vim.api.nvim_buf_get_mark(0, "<")[1]
	local e = vim.api.nvim_buf_get_mark(0, ">")[1]
	if s > e then
		s, e = e, s
	end
	return s, e
end

-- Names an editor buffer. 'acwrite' and a buffer name are both load-bearing: on a 'nofile'
-- buffer :w fails with E382 and BufWriteCmd never fires, an unnamed one fails the same way with
-- E32, and a name reused while the old buffer lives fails with E95.
local editor_seq = 0

-- Nonzero while a comment editor is open. comment_list() cancels itself on WinLeave, so opening
-- an editor from its `e` key would tear the list down underneath it. A count rather than a flag,
-- because a second editor can be opened on top of the first.
local open_editors = 0

-- Comment text is written in a scratch float and committed with :w, so it can run to several
-- paragraphs. `on_done(text)` fires on EVERY exit path, with the buffer joined by "\n" on a
-- commit and nil on a cancel, raw: callers that resend a comment need it byte for byte.
-- `opts` is { lines = string[]|nil }.
function M.input_comment(on_done, opts)
	opts = opts or {}
	local seeded = opts.lines ~= nil and #opts.lines > 0
	local lines = seeded and opts.lines or { "" }
	local origin_win = vim.api.nvim_get_current_win()

	editor_seq = editor_seq + 1
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, "agent-comment://" .. editor_seq)
	vim.bo[buf].buftype = "acwrite"
	vim.bo[buf].bufhidden = "wipe"
	-- markdown, so the user's markdown snippets, keymaps and highlighting apply. textwidth is set
	-- after it because a markdown FileType hook may raise it and hard-wrap the comment.
	vim.bo[buf].filetype = "markdown"
	vim.bo[buf].textwidth = 0
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modified = false

	local width = vim.o.columns - 2
	local height = math.max(5, math.min(#lines + 2, 16))
	open_editors = open_editors + 1
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
		col = 0,
		style = "minimal",
		border = "rounded",
		title = { { " 💬 Comment ", "AgentCommentsText" } },
		title_pos = "center",
		footer = { { " :w send  ·  :q cancel ", "Comment" } },
		footer_pos = "center",
	})
	-- A wrapped continuation line would otherwise start at column zero, and column zero is where
	-- a new item begins in the rendered message, so the marker is what keeps the two apart.
	vim.wo[win].wrap = true
	vim.wo[win].linebreak = true
	vim.wo[win].showbreak = "↪ "
	-- The float inherits the code window's fold settings, and a markdown parser gives a typed fence
	-- or heading something to fold.
	vim.wo[win].foldenable = false
	vim.api.nvim_win_set_cursor(win, { #lines, 0 })
	if not seeded then
		vim.cmd("startinsert")
	end

	local committed = nil
	local grp = vim.api.nvim_create_augroup("AgentCommentsEditor" .. buf, { clear = true })

	vim.api.nvim_create_autocmd("BufWriteCmd", {
		group = grp,
		buffer = buf,
		callback = function(ev)
			committed = table.concat(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false), "\n")
			-- BufWriteCmd does not clear 'modified' itself, and :wq would then hit E37.
			vim.bo[ev.buf].modified = false
			-- Deferred: closing the window here makes the :q half of :wq land on a second,
			-- innocent window. By the time this runs that :q has closed the editor itself.
			vim.schedule(function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			end)
		end,
	})

	-- :q on a modified editor is E37; clearing 'modified' turns it into a plain cancel.
	vim.api.nvim_create_autocmd("QuitPre", {
		group = grp,
		buffer = buf,
		callback = function(ev)
			vim.bo[ev.buf].modified = false
		end,
	})

	-- The single teardown funnel. 'bufhidden' is "wipe", so :w, :wq, ZZ, :q, :q! and :bd
	-- all arrive here and on_done fires exactly once.
	vim.api.nvim_create_autocmd("BufWipeout", {
		group = grp,
		buffer = buf,
		callback = function()
			open_editors = open_editors - 1
			vim.schedule(function()
				if vim.api.nvim_win_is_valid(origin_win) then
					vim.api.nvim_set_current_win(origin_win)
				end
				on_done(committed)
			end)
		end,
	})
end

-- The callout rendered ABOVE the first annotated line. Above, not below: a note
-- sitting under its block reads as a label for whatever code follows it.
-- The corner opens downward (╭─) into the rail beneath it.
function M._callout(text)
	return { { { "╭─ ", "AgentCommentsSign" }, { "💬 " .. text, "AgentCommentsText" } } }
end

function M.decorate(id)
	local c = comments.get(id)
	if not c then
		return
	end
	local ns = M.ns
	-- 1. Rail + tint on every line of the block. ▌ (half block) fills the sign
	--    cell solidly, so the rail reads as one continuous stripe down the block
	--    instead of a dotted column of glyphs.
	--    A whole-file comment gets no rail, which would claim it is about line 1.
	local bars = {}
	for line = c.start_line, c.whole_file and 0 or c.end_line do
		bars[#bars + 1] = vim.api.nvim_buf_set_extmark(c.bufnr, ns, line - 1, 0, {
			sign_text = "▌",
			sign_hl_group = "AgentCommentsSign",
			line_hl_group = "AgentCommentsLine",
			right_gravity = false,
		})
	end

	-- 2. Callout above the first line, opening into the rail below it. A draft has no text to
	--    summarise and gets the rail alone: an empty bubble would push the code down a line to
	--    say nothing, while the rail is the part that answers "which lines am I commenting on".
	local callout
	if c.text then
		callout = vim.api.nvim_buf_set_extmark(c.bufnr, ns, c.start_line - 1, 0, {
			virt_lines = M._callout(M.summary(c)),
			virt_lines_above = true,
		})
	end
	decorations[id] = { bars = bars, callout = callout, bufnr = c.bufnr }
end

function M.undecorate(id)
	local marks = decorations[id]
	if marks and vim.api.nvim_buf_is_valid(marks.bufnr) then
		for _, bar in ipairs(marks.bars) do
			vim.api.nvim_buf_del_extmark(marks.bufnr, M.ns, bar)
		end
		if marks.callout then
			vim.api.nvim_buf_del_extmark(marks.bufnr, M.ns, marks.callout)
		end
	end
	decorations[id] = nil
end

-- One line of display text for a comment, whose own text is a rendered block running to several
-- lines. A line count rather than a guess at which of them carries the annotation: the block is
-- freely editable, so any such heuristic eventually points at the wrong line and reads as a bug.
function M.summary(c)
	if not c.text or c.text == "" then
		return ""
	end
	local n = #vim.split(c.text, "\n", { plain = true })
	return string.format("%d line%s", n, n == 1 and "" or "s")
end

function M.comment_row(c)
	if c.whole_file then
		return string.format("%s  %s", vim.fn.fnamemodify(c.file, ":t"), M.summary(c))
	end
	return string.format(
		"%s:%d-%d  %s",
		vim.fn.fnamemodify(c.file, ":t"),
		c.start_line,
		c.end_line,
		M.summary(c)
	)
end

-- Interactive comment list: a rounded floating box (with a shortcut-hint footer)
-- listing one row per comment. Moving the cursor auto-previews (jumps the code
-- window to that comment); <CR> jumps, `e` edits, `dd` deletes, `q`/<Esc> cancels.
-- `handlers.edit(c, refresh)` and `handlers.delete(c)` do the actual work.
function M.comment_list(handlers)
	-- Ahead of the no-comments early return below, so a list left behind by any path that forgot
	-- to close it can never strand a float the user cannot reopen and dismiss.
	if open_list then
		open_list.dismiss()
	end
	local code_win = vim.api.nvim_get_current_win()
	-- Browsing the list previews by moving the code window. Save where it was so cancelling puts
	-- it back; only <CR> is allowed to leave the window somewhere new.
	local origin = {
		buf = vim.api.nvim_win_get_buf(code_win),
		view = vim.api.nvim_win_call(code_win, vim.fn.winsaveview),
	}
	local rows = comments.list()
	if #rows == 0 then
		vim.notify("agent-comments: no comments", vim.log.levels.INFO)
		return
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "agent-comments"

	local function win_config()
		local width = 46
		for _, c in ipairs(rows) do
			width = math.max(width, vim.fn.strdisplaywidth(M.comment_row(c)) + 2)
		end
		width = math.min(width, math.max(46, vim.o.columns - 6))
		local height = math.max(1, math.min(#rows, 12))
		return {
			relative = "editor",
			width = width,
			height = height,
			row = math.max(0, vim.o.lines - height - 4),
			col = math.max(0, math.floor((vim.o.columns - width) / 2)),
			style = "minimal",
			border = "rounded",
			title = { { " 💬 Comments ", "AgentCommentsText" } },
			title_pos = "center",
			footer = {
				{
					" ↑↓ preview  ·  ⏎ jump  ·  e edit  ·  dd delete  ·  q cancel ",
					"Comment",
				},
			},
			footer_pos = "center",
		}
	end

	local win = vim.api.nvim_open_win(buf, true, win_config())
	vim.wo[win].cursorline = true
	vim.wo[win].wrap = false

	local grp = vim.api.nvim_create_augroup("AgentCommentsList" .. buf, { clear = true })

	local function restore()
		if not vim.api.nvim_win_is_valid(code_win) or not vim.api.nvim_buf_is_valid(origin.buf) then
			return
		end
		if vim.api.nvim_win_get_buf(code_win) ~= origin.buf then
			-- Same E37 guard as preview(): a modified buffer with 'hidden' off refuses to swap out.
			if not pcall(vim.api.nvim_win_set_buf, code_win, origin.buf) then
				return
			end
		end
		vim.api.nvim_win_call(code_win, function()
			vim.fn.winrestview(origin.view)
		end)
	end

	-- Set by every deliberate takedown, so the WinLeave handler below stays out of the way. Every
	-- exit path funnels through dismiss(), <CR> included, and closing the float fires WinLeave.
	local closing = false

	local function dismiss()
		closing = true
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		pcall(vim.api.nvim_del_augroup_by_id, grp)
		-- Guarded so a dismiss arriving late cannot drop a list opened since.
		if open_list and open_list.win == win then
			open_list = nil
		end
	end

	local function close()
		restore()
		dismiss()
	end

	local function render()
		rows = comments.list()
		if #rows == 0 then
			close()
			return false
		end
		local lines = {}
		for _, c in ipairs(rows) do
			lines[#lines + 1] = M.comment_row(c)
		end
		vim.bo[buf].modifiable = true
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].modifiable = false
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_set_config(win, win_config())
		end
		return true
	end

	local function current()
		if not vim.api.nvim_win_is_valid(win) then
			return nil
		end
		return rows[vim.api.nvim_win_get_cursor(win)[1]]
	end

	local function preview()
		local c = current()
		if
			not c
			or not vim.api.nvim_win_is_valid(code_win)
			or not vim.api.nvim_buf_is_valid(c.bufnr)
		then
			return
		end
		-- Guarded: switching the code window to another buffer can fail (E37) when
		-- its current buffer is modified and 'hidden' is off. Skip the preview
		-- rather than throw; the list stays usable.
		if not pcall(vim.api.nvim_win_set_buf, code_win, c.bufnr) then
			return
		end
		local line = math.min(c.start_line, math.max(1, vim.api.nvim_buf_line_count(c.bufnr)))
		vim.api.nvim_win_set_cursor(code_win, { line, 0 })
		vim.api.nvim_win_call(code_win, function()
			vim.cmd("normal! zz")
		end)
	end

	open_list = { win = win, buf = buf, render = render, dismiss = dismiss }

	render()
	preview()

	vim.api.nvim_create_autocmd("CursorMoved", { group = grp, buffer = buf, callback = preview })

	vim.api.nvim_create_autocmd("WinLeave", {
		group = grp,
		buffer = buf,
		callback = function()
			-- Navigating away without <CR> is a cancel. Deferred because a WinLeave callback is
			-- not allowed to close a window; skipped while the list is coming down on purpose,
			-- since restoring then would undo the jump <CR> just made, and skipped while a
			-- comment editor is open, since `e` opens one and entering it fires this.
			vim.schedule(function()
				if not closing and open_editors == 0 then
					close()
				end
			end)
		end,
	})

	local function map(lhs, fn)
		vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true, silent = true })
	end

	map("q", close)
	map("<Esc>", close)
	-- <CR> is the jump: the preview already put the code window where the user wants it.
	map("<CR>", dismiss)
	map("e", function()
		local c = current()
		if c then
			handlers.edit(c, function()
				if render() then
					preview()
				end
			end)
		end
	end)
	-- No `nowait` here: `dd` needs the timeout to collect its second key, and binding the whole
	-- gesture keeps a stray `d` (the start of `dd`, `dw`, `diw`) from destroying a comment.
	vim.keymap.set("n", "dd", function()
		local c = current()
		if c then
			handlers.delete(c)
			if render() then
				preview()
			end
		end
	end, { buffer = buf, silent = true })
end

-- Redraw an open list from the live comment store. render() closes the window when nothing is
-- left, so clearing every comment both drops the list and puts the code window back.
function M.refresh_list()
	local list = open_list
	if not list then
		return
	end
	if not vim.api.nvim_win_is_valid(list.win) or not vim.api.nvim_buf_is_valid(list.buf) then
		open_list = nil
		return
	end
	list.render()
end

function M.pick_agent(agent_list, on_choice)
	if #agent_list == 0 then
		vim.notify("agent-comments: no agents found", vim.log.levels.WARN)
		return
	end
	-- Pure selection: send-time policy (e.g. the "working" warning) lives in the
	-- caller's on_choice, so both the picker and the auto-resolve path share it.
	vim.ui.select(
		agent_list,
		{ prompt = "Send to agent", format_item = agents.display },
		function(a)
			if a then
				on_choice(a)
			end
		end
	)
end

return M
