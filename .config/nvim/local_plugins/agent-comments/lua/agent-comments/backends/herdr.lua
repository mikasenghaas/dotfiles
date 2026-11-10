local M = {}
local exec_mod = require("agent-comments.exec")

M.name = "herdr"
M.binary = "herdr"

-- Without a session id there is nothing to scope the agent list to, so a send would
-- silently widen to every agent in every workspace. Fail with an explanation instead.
function M.available()
	if not vim.env.HERDR_WORKSPACE_ID then
		return false, "not in a herdr session (HERDR_WORKSPACE_ID is unset)"
	end
	return true
end

function M.list(exec)
	local ok_available, reason = M.available()
	if not ok_available then
		return nil, reason
	end
	exec = exec or exec_mod.default_exec
	local r = exec({ "herdr", "agent", "list" })
	if r.code ~= 0 then
		return nil,
			"herdr agent list failed: " .. (r.stderr ~= "" and r.stderr or ("exit " .. r.code))
	end
	local ok, decoded = pcall(vim.json.decode, r.stdout)
	if not ok or type(decoded) ~= "table" then
		return nil, "herdr agent list: unparseable JSON"
	end
	local raw = (decoded.result or {}).agents or {}
	local out = {}
	local here = vim.env.HERDR_WORKSPACE_ID
	for _, a in ipairs(raw) do
		if a.workspace_id == here then
			table.insert(out, {
				pane_id = a.pane_id,
				workspace_id = a.workspace_id,
				tab_id = a.tab_id,
				kind = a.agent or "unknown",
				-- No default: a multiplexer without an agent supervisor reports no status,
				-- and callers must be able to tell that from a real one.
				status = a.agent_status,
				cwd = a.cwd or "",
				title = a.terminal_title or a.agent or "agent",
			})
		end
	end
	table.sort(out, function(x, y)
		return x.title < y.title
	end)
	return out
end

-- Resolve the one agent to target without a picker, or nil when it's ambiguous.
-- `list` is already workspace-scoped by M.list. Narrowest unambiguous match wins:
--   1. a single agent sharing the current tab (HERDR_TAB_ID), the sibling pane,
--      same convention the file picker uses to find "the agent in this tab";
--   2. otherwise, a lone agent in the workspace.
-- Anything ambiguous (2+ candidates) returns nil so the caller shows the picker.
function M.resolve(list, _)
	if #list == 1 then
		return list[1]
	end
	local tab = vim.env.HERDR_TAB_ID
	if tab then
		local in_tab = {}
		for _, a in ipairs(list) do
			if a.tab_id == tab then
				table.insert(in_tab, a)
			end
		end
		if #in_tab == 1 then
			return in_tab[1]
		end
	end
	return nil
end

function M.display(agent)
	-- Lead with the agent kind (pi/claude/codex, the actual agent identity), then its
	-- state and where it's running. (The terminal title tended to just repeat the
	-- workspace/repo name shown by the cwd tail.)
	local parts = { agent.kind }
	if agent.status then
		table.insert(parts, agent.status)
	end
	table.insert(parts, vim.fn.fnamemodify(agent.cwd or "", ":t"))
	return table.concat(parts, " · ")
end

function M.send(target, text, opts, exec)
	opts = opts or {}
	exec = exec or exec_mod.default_exec
	if opts.submit then
		-- deliver the text and submit it (presses Enter for you)
		local r = exec({ "herdr", "agent", "prompt", target, text })
		if r.code ~= 0 then
			return false,
				"herdr agent prompt failed: "
					.. (r.stderr ~= "" and r.stderr or ("exit " .. r.code))
		end
	else
		-- deliver the text without submitting it
		local r = exec({ "herdr", "pane", "send-text", target, text })
		if r.code ~= 0 then
			return false,
				"herdr pane send-text failed: "
					.. (r.stderr ~= "" and r.stderr or ("exit " .. r.code))
		end
	end
	return true
end

return M
