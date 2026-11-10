local M = {}
local exec_mod = require("agent-comments.exec")

M.name = "tmux"
M.binary = "tmux"

-- tmux does not expand escapes in a -F format, so the separator has to be a real tab byte:
-- this must stay a double-quoted literal and never become a [[long bracket]] string.
local PANE_FORMAT = "#{pane_id}\t#{window_id}\t#{window_index}\t#{session_id}"
	.. "\t#{pane_current_command}\t#{pane_current_path}\t#{pane_title}"

local PANE_PATTERN = "^([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t(.*)$"

-- Read lazily, not at require time: a top-level require of agent-comments closes the
-- cycle agents -> backends -> tmux -> init, and setup() rebinds M.config to a fresh table.
local function rules()
	return require("agent-comments").config.agents or {}
end

local function rule_for(kind)
	for _, rule in ipairs(rules()) do
		if rule.kind == kind then
			return rule
		end
	end
	return nil
end

local function matches(rule, command, title)
	if rule.title and title:match(rule.title) then
		return true
	end
	if rule.command and command:match(rule.command) then
		return true
	end
	return false
end

local function kind_of(command, title)
	for _, rule in ipairs(rules()) do
		if matches(rule, command, title) then
			return rule.kind
		end
	end
	return nil
end

function M.available()
	if not vim.env.TMUX then
		return false, "not in a tmux session (TMUX is unset)"
	end
	-- Every argv below carries the pane id, and a nil in the middle of a Lua array
	-- truncates it, so the call would silently lose its target rather than fail.
	if not vim.env.TMUX_PANE then
		return false, "no tmux pane id (TMUX_PANE is unset)"
	end
	return true
end

function M.list(exec)
	local ok_available, reason = M.available()
	if not ok_available then
		return nil, reason
	end
	exec = exec or exec_mod.default_exec
	local r = exec({ "tmux", "list-panes", "-s", "-t", vim.env.TMUX_PANE, "-F", PANE_FORMAT })
	if r.code ~= 0 then
		return nil,
			"tmux list-panes failed: " .. (r.stderr ~= "" and r.stderr or ("exit " .. r.code))
	end
	local out = {}
	for _, line in ipairs(vim.split(r.stdout, "\n", { plain = true })) do
		-- A pane title can contain a newline, which splits one pane over two lines;
		-- anything that does not parse as a whole record is dropped rather than indexed.
		local pane_id, window_id, window_index, session_id, command, cwd, title =
			line:match(PANE_PATTERN)
		if pane_id and pane_id ~= vim.env.TMUX_PANE then
			local kind = kind_of(command, title)
			if kind then
				table.insert(out, {
					pane_id = pane_id,
					workspace_id = session_id,
					tab_id = window_id,
					kind = kind,
					-- No status: tmux has no agent supervisor, and callers must be able to
					-- tell a missing status from a real one.
					cwd = cwd,
					title = title,
					index = window_index,
				})
			end
		end
	end
	table.sort(out, function(x, y)
		return (tonumber(x.index) or 0) < (tonumber(y.index) or 0)
	end)
	return out
end

-- Resolve the one pane to target without a picker, or nil when it's ambiguous: a lone
-- candidate, else a single candidate sharing the current window. nil is not an error;
-- it means the caller shows the picker.
function M.resolve(list, exec)
	if #list == 1 then
		return list[1]
	end
	if not vim.env.TMUX_PANE then
		return nil
	end
	exec = exec or exec_mod.default_exec
	local r = exec({ "tmux", "display-message", "-p", "-t", vim.env.TMUX_PANE, "#{window_id}" })
	if r.code ~= 0 then
		return nil
	end
	local window_id = r.stdout:gsub("%s+$", "")
	local here = {}
	for _, a in ipairs(list) do
		if a.tab_id == window_id then
			table.insert(here, a)
		end
	end
	if #here == 1 then
		return here[1]
	end
	return nil
end

function M.display(agent)
	local title = agent.title or ""
	local rule = rule_for(agent.kind)
	if rule and rule.title then
		local from, to = title:find(rule.title)
		if from == 1 then
			title = title:sub(to + 1):gsub("^%s+", "")
		end
	end
	if title == "" then
		return string.format("%s: %s", agent.index, agent.kind)
	end
	return string.format("%s: %s - %s", agent.index, agent.kind, title)
end

function M.send(target, text, opts, exec)
	opts = opts or {}
	exec = exec or exec_mod.default_exec
	-- Buffer names are server-wide, so two nvim instances would otherwise clobber each
	-- other between the set and the paste.
	local name = "agent-comments-" .. vim.fn.getpid()
	local r = exec({ "tmux", "set-buffer", "-b", name, "--", text })
	if r.code ~= 0 then
		return false,
			"tmux set-buffer failed: " .. (r.stderr ~= "" and r.stderr or ("exit " .. r.code))
	end
	-- -r stops tmux turning each linefeed into a carriage return, which would make the
	-- receiving TUI submit every line as its own prompt.
	r = exec({ "tmux", "paste-buffer", "-p", "-r", "-d", "-b", name, "-t", target })
	if r.code ~= 0 then
		-- -d only deletes on success, so the whole prompt would be left sitting in a buffer.
		exec({ "tmux", "delete-buffer", "-b", name })
		return false,
			"tmux paste-buffer failed: " .. (r.stderr ~= "" and r.stderr or ("exit " .. r.code))
	end
	if opts.submit then
		r = exec({ "tmux", "send-keys", "-t", target, "Enter" })
		if r.code ~= 0 then
			return false,
				"tmux send-keys failed: " .. (r.stderr ~= "" and r.stderr or ("exit " .. r.code))
		end
	end
	return true
end

return M
