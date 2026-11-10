-- :AgentComment user command with scoped subcommands (comment/list/send/submit) and
-- completions. Private module; the public API lives in agent-comments.init.
local M = {}

local subcommands = { "comment", "list", "send", "submit" }

-- Idempotent: delete-then-create also replaces lazy.nvim's `cmd` placeholder.
function M.register()
	pcall(vim.api.nvim_del_user_command, "AgentComment")
	vim.api.nvim_create_user_command("AgentComment", function(opts)
		require("agent-comments.commands").run(opts)
	end, {
		nargs = "?",
		range = true,
		desc = "agent-comments: comment, list, send, or submit code annotations",
		complete = function(arg_lead, cmdline)
			return require("agent-comments.commands").complete(arg_lead, cmdline)
		end,
	})
end

-- Complete the subcommand word only; the cmdline anchor skips any range
-- prefix (:'<,'>, :5,10) and stops after a full subcommand.
function M.complete(arg_lead, cmdline)
	local _, after = cmdline:find("AgentComment%s+", 1)
	if not after then
		return {}
	end
	local lead = cmdline:sub(after + 1)
	if not lead:match("^%w*$") then
		return {}
	end
	return vim.iter(subcommands)
		:filter(function(s)
			return vim.startswith(s, lead)
		end)
		:totable()
end

-- Dispatch a subcommand; `comment` honors the command range (cursor line by
-- default, or :'<,'>/:5,10 when given).
function M.run(opts)
	local hn = require("agent-comments")
	local sub = opts.fargs[1]
	if sub == "comment" then
		hn.comment_range(opts.line1, opts.line2)
	elseif sub == "list" then
		hn.list_comments()
	elseif sub == "send" then
		hn.send_all({ submit = false })
	elseif sub == "submit" then
		hn.send_all({ submit = true })
	else
		vim.notify(
			string.format(
				"AgentComment: unknown subcommand %q (expected: %s)",
				sub or "",
				table.concat(subcommands, ", ")
			),
			vim.log.levels.ERROR,
			{ title = "agent-comments" }
		)
	end
end

return M
