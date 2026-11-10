local M = {}
-- Range tracking only: one extmark per comment, so a query here counts comments.
-- Decorations live in their own namespace (see ui.ns).
M.ns = vim.api.nvim_create_namespace("agent-comments")
local store = {} -- id -> { bufnr, extmark, text, created_at, whole_file }
local next_id = 1

-- `opts.whole_file` makes a comment on the file rather than on start_line..end_line; its extmark
-- still exists so the buffer it belongs to is tracked like any other.
function M.add(bufnr, start_line, end_line, text, opts)
	local whole_file = opts and opts.whole_file or false
	local id = next_id
	next_id = next_id + 1
	local extmark =
		vim.api.nvim_buf_set_extmark(bufnr, M.ns, whole_file and 0 or start_line - 1, 0, {
			end_row = not whole_file and end_line or nil,
			end_col = not whole_file and 0 or nil,
			right_gravity = false,
			end_right_gravity = not whole_file or nil,
		})
	store[id] = {
		bufnr = bufnr,
		extmark = extmark,
		text = text,
		created_at = os.time(),
		whole_file = whole_file,
	}
	return id
end

local function resolve(id)
	local e = store[id]
	if not e or not vim.api.nvim_buf_is_valid(e.bufnr) then
		return nil
	end
	local pos = vim.api.nvim_buf_get_extmark_by_id(e.bufnr, M.ns, e.extmark, { details = true })
	if not pos or #pos == 0 then
		return nil
	end
	local start_line = e.whole_file and 1 or pos[1] + 1
	-- pos[3].end_row is 0-indexed and exclusive; numerically that equals the
	-- 1-indexed inclusive end line, so no conversion is needed here.
	local end_line = pos[3] and pos[3].end_row or (pos[1] + 1)
	if e.whole_file or end_line < start_line then
		end_line = start_line
	end
	-- A draft has no text yet, and the live buffer is what its seed's [unsaved] marker will be
	-- derived from. A committed comment is a snapshot, and the prompt's preamble promises to
	-- explain the markers the message actually shows, so its [unsaved] state is read back out of
	-- the text it froze rather than from a buffer that has since been written.
	local modified
	if e.text == nil then
		modified = vim.bo[e.bufnr].modified
	else
		modified = e.text:find("[unsaved]", 1, true) ~= nil
	end
	return {
		id = id,
		bufnr = e.bufnr,
		file = vim.api.nvim_buf_get_name(e.bufnr),
		start_line = start_line,
		end_line = end_line,
		text = e.text,
		modified = modified,
		created_at = e.created_at,
		whole_file = e.whole_file,
	}
end

function M.get(id)
	return resolve(id)
end

function M.list()
	local out = {}
	for id, e in pairs(store) do
		-- A draft (anchored at editor-open time, text not written yet) is not a comment: it must
		-- reach neither the prompt nor the comment list.
		local c = e.text ~= nil and resolve(id) or nil
		if c then
			table.insert(out, c)
		end
	end
	table.sort(out, function(a, b)
		if a.file ~= b.file then
			return a.file < b.file
		end
		return a.start_line < b.start_line
	end)
	return out
end

function M.edit(id, new_text)
	if not store[id] then
		return false
	end
	store[id].text = new_text
	return true
end

function M.delete(id)
	local e = store[id]
	if not e then
		return false
	end
	if vim.api.nvim_buf_is_valid(e.bufnr) then
		vim.api.nvim_buf_del_extmark(e.bufnr, M.ns, e.extmark)
	end
	store[id] = nil
	return true
end

function M.clear()
	for id in pairs(store) do
		M.delete(id)
	end
end

function M.snippet(id)
	local c = resolve(id)
	if not c then
		return nil
	end
	if c.whole_file then
		return {}
	end
	return vim.api.nvim_buf_get_lines(c.bufnr, c.start_line - 1, c.end_line, false)
end

return M
