local M = {}
local comments = require("agent-comments.comments")
local prompt = require("agent-comments.prompt")
local agents = require("agent-comments.agents")
local dispatch = require("agent-comments.dispatch")
local ui = require("agent-comments.ui")

M.config = {
	clear_after_send = true,
	agents = {
		{ kind = "claude", title = "^✳", command = "^%d+%.%d+%.%d+$" },
		{ kind = "codex", command = "^codex$" },
		{ kind = "prime-agent", command = "^prime%-agent$" },
	},
}

-- A message wider than the command line triggers the hit-enter prompt, so trim to one line. The
-- last column stays empty because filling it scrolls the message area too.
local function fit_one_line(msg)
	local max_width = vim.v.echospace - 1
	if vim.fn.strdisplaywidth(msg) <= max_width then
		return msg
	end
	local nchars = vim.fn.strcharlen(msg)
	while nchars > 0 and vim.fn.strdisplaywidth(vim.fn.strcharpart(msg, 0, nchars)) >= max_width do
		nchars = nchars - 1
	end
	return vim.fn.strcharpart(msg, 0, nchars) .. "…"
end

function M.setup(config)
	config = config or {}
	-- vim.tbl_deep_extend merges lists by index, so a caller supplying one rule would
	-- silently keep the defaults sitting behind it. The rule list is replaced wholesale.
	local agent_rules = config.agents
	M.config = vim.tbl_deep_extend("force", M.config, config)
	if agent_rules then
		M.config.agents = agent_rules
	end
	-- Ensure :AgentComment is registered (also done from plugin/agent-comments.lua).
	require("agent-comments.commands").register()
end

local function open_editor(id)
	ui.decorate(id)
	-- The annotation is typed into the rendered item itself, so it can sit between two quoted code
	-- lines. Seeding from prompt.item is what makes an untouched buffer send as the item it was
	-- seeded from.
	local seed = prompt.item(comments.get(id), comments.snippet(id))
	-- One past prompt.item's own trailing blank, so the cursor starts below that separator and
	-- the first thing typed does not land flush against the last quoted line.
	seed[#seed + 1] = ""
	ui.input_comment(function(text)
		-- input_comment reports every exit, cancel included.
		ui.undecorate(id)
		if not text or text:match("^%s*$") then
			comments.delete(id)
			return
		end
		comments.edit(id, text)
		ui.decorate(id)
	end, { lines = seed })
end

-- Range primitive behind comment_line(), comment_selection(), and :AgentComment comment.
function M.comment_range(start_line, end_line)
	local bufnr = vim.api.nvim_get_current_buf()
	-- Anchored before the editor opens rather than after it closes: the editor can be left for the
	-- code window and the buffer edited underneath it, and only an extmark keeps the range on the
	-- lines the comment was aimed at.
	open_editor(comments.add(bufnr, start_line, end_line, nil))
end

-- A comment on the current file as a whole: the seed is the bare path, with no range or quote.
function M.comment_file()
	open_editor(comments.add(vim.api.nvim_get_current_buf(), 1, 1, nil, { whole_file = true }))
end

function M.comment_selection()
	vim.cmd([[execute "normal! \<esc>"]]) -- materialize '< '> marks
	local s, e = ui.visual_range()
	M.comment_range(s, e)
end

function M.comment_line()
	local l = vim.api.nvim_win_get_cursor(0)[1]
	M.comment_range(l, l)
end

-- Edit a comment's text in place (undecorate → edit → re-decorate so the callout
-- reflects the new text). `on_done` (optional) fires after the input closes.
function M.edit_comment(c, on_done)
	ui.input_comment(function(t)
		if t and t ~= "" and t ~= c.text then
			ui.undecorate(c.id)
			comments.edit(c.id, t)
			ui.decorate(c.id)
		end
		if on_done then
			on_done()
		end
	end, { lines = vim.split(c.text, "\n", { plain = true }) })
end

function M.delete_comment(c)
	ui.undecorate(c.id)
	comments.delete(c.id)
end

-- Interactive list: hover auto-jumps to each comment, <CR> edits, `d` deletes,
-- `q`/<Esc> closes. No secondary jump/edit/delete menu.
function M.list_comments()
	ui.comment_list({
		edit = function(c, refresh)
			M.edit_comment(c, refresh)
		end,
		delete = function(c)
			M.delete_comment(c)
		end,
	})
end

function M.send_all(opts)
	local list = comments.list()
	if #list == 0 then
		vim.notify("agent-comments: no comments to send", vim.log.levels.INFO)
		return
	end
	local items = {}
	for _, c in ipairs(list) do
		table.insert(items, { comment = c })
	end
	local text = prompt.format(items)
	local agent_list, err = agents.list()
	if not agent_list then
		vim.notify("agent-comments: " .. err, vim.log.levels.ERROR)
		return
	end
	-- Single funnel for every send (both the resolved and picked paths), so the
	-- "agent is working" warning lives in exactly one place.
	local function deliver(agent)
		local ok, derr = dispatch.send(agent.pane_id, text, opts)
		if not ok then
			vim.notify("agent-comments: " .. derr, vim.log.levels.ERROR)
			return
		end
		if M.config.clear_after_send then
			for _, c in ipairs(list) do
				M.delete_comment(c)
			end
		end
		-- A send can be fired from inside the comment list, which would otherwise go on showing
		-- comments the store no longer holds.
		ui.refresh_list()
		-- One message per send: a second one in the same tick would also force the hit-enter prompt.
		local working = agent.status == "working"
		local msg = string.format(
			"agent-comments: sent %d comment(s)%s to %s",
			#list,
			working and " (agent was working)" or "",
			agent.title
		)
		vim.notify(fit_one_line(msg), working and vim.log.levels.WARN or vim.log.levels.INFO)
	end
	-- Skip the picker when the target is unambiguous (the common one-agent case);
	-- fall back to the picker only when 2+ agents could plausibly be meant.
	local agent = agents.resolve(agent_list)
	if agent then
		deliver(agent)
	else
		ui.pick_agent(agent_list, deliver)
	end
end

return M
