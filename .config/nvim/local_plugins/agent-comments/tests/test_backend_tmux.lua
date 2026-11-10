local tmux = require("agent-comments.backends.tmux")
local hn = require("agent-comments")

local TMUX_SOCKET = "/tmp/tmux-test/default,1,0"
local claude_rule = { kind = "claude", title = "^✳", command = "^%d+%.%d+%.%d+$" }
local default_rules = hn.config.agents

-- The separator has to be a real tab byte, so every fixture goes through this concat and
-- never through a [[long bracket]] literal, where \t would stay a backslash and a t.
local function panes(...)
	local lines = {}
	for _, fields in ipairs({ ... }) do
		lines[#lines + 1] = table.concat(fields, "\t")
	end
	return table.concat(lines, "\n")
end

local function fake_exec(out, code)
	return function(_)
		return { code = code or 0, stdout = out, stderr = "" }
	end
end

local function recorder(fail_on)
	local calls = {}
	return calls,
		function(argv)
			table.insert(calls, argv)
			if fail_on and #calls == fail_on then
				return { code = 1, stdout = "", stderr = "boom" }
			end
			return { code = 0, stdout = "", stderr = "" }
		end
end

local function with_session(env, fn)
	local previous_tmux, previous_pane = vim.env.TMUX, vim.env.TMUX_PANE
	local previous_rules = hn.config.agents
	vim.env.TMUX = env.TMUX
	vim.env.TMUX_PANE = env.TMUX_PANE
	hn.config.agents = env.agents or { claude_rule }
	local ok, err = pcall(fn)
	vim.env.TMUX, vim.env.TMUX_PANE = previous_tmux, previous_pane
	hn.config.agents = previous_rules
	if not ok then
		error(err, 0)
	end
end

T.test("tmux: available reports the missing session", function()
	with_session({}, function()
		local ok, reason = tmux.available()
		T.eq(ok, false)
		T.ok(reason and reason:find("TMUX", 1, true), "reason names the env var")
	end)
end)

T.test("tmux: available is true inside a session", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		T.eq(tmux.available(), true)
	end)
end)

T.test("tmux: a session without a pane id is unavailable and never execs", function()
	with_session({ TMUX = TMUX_SOCKET }, function()
		local ok, reason = tmux.available()
		T.eq(ok, false)
		T.ok(reason and reason:find("TMUX_PANE", 1, true), "reason names the env var")
		local list, err = tmux.list(function()
			error("list must not exec without a pane id to target")
		end)
		T.eq(list, nil)
		T.ok(err and err:find("TMUX_PANE", 1, true), "the error names the env var")
	end)
end)

T.test("tmux: list without a session returns an error, not a widened list", function()
	with_session({}, function()
		local fixture = panes({ "%1", "@1", "1", "$0", "zsh", "/tmp/a", "✳ review" })
		local list, err = tmux.list(fake_exec(fixture))
		T.eq(list, nil)
		T.ok(err and err:find("TMUX", 1, true), "error names the missing session")
	end)
end)

T.test("tmux: list drops the pane nvim is running in", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local fixture = panes(
			{ "%0", "@1", "1", "$0", "nvim", "/tmp/a", "✳ self" },
			{ "%1", "@1", "1", "$0", "zsh", "/tmp/a", "✳ review" }
		)
		local list = tmux.list(fake_exec(fixture))
		T.eq(#list, 1)
		T.eq(list[1].pane_id, "%1")
	end)
end)

T.test("tmux: list drops panes that match no rule", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local fixture = panes(
			{ "%1", "@1", "1", "$0", "zsh", "/tmp/a", "zsh" },
			{ "%2", "@1", "1", "$0", "zsh", "/tmp/a", "✳ review" }
		)
		local list = tmux.list(fake_exec(fixture))
		T.eq(#list, 1)
		T.eq(list[1].pane_id, "%2")
	end)
end)

T.test("tmux: list stamps the kind of the rule that matched", function()
	with_session({
		TMUX = TMUX_SOCKET,
		TMUX_PANE = "%0",
		agents = { claude_rule, { kind = "codex", command = "^codex$" } },
	}, function()
		local fixture = panes(
			{ "%1", "@1", "1", "$0", "zsh", "/tmp/a", "✳ review" },
			{ "%2", "@1", "2", "$0", "codex", "/tmp/b", "plain title" }
		)
		local list = tmux.list(fake_exec(fixture))
		T.eq(#list, 2)
		T.eq(list[1].kind, "claude", "a title-only match takes its rule's kind")
		T.eq(list[2].kind, "codex", "a command-only match takes its rule's kind")
	end)
end)

T.test("tmux: candidate fields carry the pane, window and session ids", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local fixture = panes({ "%7", "@3", "4", "$2", "zsh", "/tmp/proj", "✳ review" })
		local list = tmux.list(fake_exec(fixture))
		T.eq(list[1], {
			pane_id = "%7",
			workspace_id = "$2",
			tab_id = "@3",
			kind = "claude",
			cwd = "/tmp/proj",
			title = "✳ review",
			index = "4",
		})
		T.eq(list[1].status, nil, "tmux reports no agent status")
	end)
end)

T.test("tmux: a tab inside a pane title does not corrupt the parse", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local fixture = panes({ "%1", "@1", "1", "$0", "zsh", "/tmp/a", "✳ one\ttwo" })
		local list = tmux.list(fake_exec(fixture))
		T.eq(#list, 1)
		T.eq(list[1].title, "✳ one\ttwo")
		T.eq(list[1].cwd, "/tmp/a")
	end)
end)

T.test("tmux: a line that is not a whole record is skipped", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local split_record = panes({ "%1", "@1", "1", "$0", "zsh", "/tmp/a", "✳ first half" })
			.. "\nsecond half"
		local whole_record = panes({ "%2", "@1", "2", "$0", "zsh", "/tmp/b", "✳ whole" })
		local list = tmux.list(fake_exec(split_record .. "\n" .. whole_record))
		T.eq(#list, 2)
		T.eq(list[1].title, "✳ first half")
		T.eq(list[2].title, "✳ whole")
	end)
end)

T.test("tmux: an empty pane title still yields a candidate when the command matches", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local fixture = panes({ "%1", "@1", "1", "$0", "0.2.134", "/tmp/a", "" })
		local list = tmux.list(fake_exec(fixture))
		T.eq(#list, 1)
		T.eq(list[1].kind, "claude")
		T.eq(list[1].title, "")
	end)
end)

T.test("tmux: list sorts by window index numerically", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local fixture = panes(
			{ "%1", "@10", "10", "$0", "zsh", "/tmp/a", "✳ ten" },
			{ "%2", "@9", "9", "$0", "zsh", "/tmp/b", "✳ nine" }
		)
		local list = tmux.list(fake_exec(fixture))
		T.eq(list[1].index, "9")
		T.eq(list[2].index, "10")
	end)
end)

T.test("tmux: the default rules detect every supported harness", function()
	local harnesses = {
		{ command = "2.1.280", title = "✳ review", kind = "claude" },
		{ command = "codex", title = "Ready", kind = "codex" },
		{ command = "prime-agent", title = "prime-agent - repo", kind = "prime-agent" },
	}
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0", agents = default_rules }, function()
		local rows = { { "%99", "@1", "99", "$0", "zsh", "/tmp/shell", "zsh" } }
		for i, h in ipairs(harnesses) do
			rows[#rows + 1] = { "%" .. i, "@1", tostring(i), "$0", h.command, "/tmp/a", h.title }
		end
		local list = tmux.list(fake_exec(panes(unpack(rows))))
		T.eq(#list, #harnesses, "a plain shell is not an agent")
		for i, h in ipairs(harnesses) do
			T.eq(list[i].kind, h.kind, h.command .. " is detected")
		end
	end)
end)

T.test("tmux: list reads rules assigned after the module was required", function()
	with_session({
		TMUX = TMUX_SOCKET,
		TMUX_PANE = "%0",
		agents = { { kind = "aider", command = "^aider$" } },
	}, function()
		local fixture = panes({ "%1", "@1", "1", "$0", "aider", "/tmp/a", "plain" })
		local list = tmux.list(fake_exec(fixture))
		T.eq(#list, 1)
		T.eq(list[1].kind, "aider")
	end)
end)

T.test("tmux: list scopes list-panes to the session holding the current pane", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local calls = {}
		tmux.list(function(argv)
			table.insert(calls, argv)
			return { code = 0, stdout = "", stderr = "" }
		end)
		T.eq(#calls, 1)
		T.eq({ calls[1][1], calls[1][2], calls[1][3], calls[1][4], calls[1][5], calls[1][6] }, {
			"tmux",
			"list-panes",
			"-s",
			"-t",
			"%0",
			"-F",
		})
		T.ok(calls[1][7]:find("#{pane_id}", 1, true), "the format asks for the pane id")
		T.ok(calls[1][7]:find("\t", 1, true), "the format separator is a real tab byte")
	end)
end)

T.test("tmux: a failed list-panes returns err", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local list, err = tmux.list(fake_exec("", 1))
		T.eq(list, nil)
		T.ok(err and err:match("tmux"), "the error names tmux")
	end)
end)

T.test("tmux: resolve returns the lone candidate without asking tmux", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local calls, exec = recorder()
		local a = tmux.resolve({ { pane_id = "%1", tab_id = "@1" } }, exec)
		T.eq(a.pane_id, "%1")
		T.eq(#calls, 0)
	end)
end)

T.test("tmux: resolve picks the single candidate in the current window", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local a = tmux.resolve({
			{ pane_id = "%1", tab_id = "@1" },
			{ pane_id = "%2", tab_id = "@2" },
			{ pane_id = "%3", tab_id = "@3" },
		}, fake_exec("@2\n"))
		T.eq(a.pane_id, "%2")
	end)
end)

T.test("tmux: resolve returns nil when two candidates share the current window", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local a = tmux.resolve({
			{ pane_id = "%1", tab_id = "@2" },
			{ pane_id = "%2", tab_id = "@2" },
		}, fake_exec("@2\n"))
		T.eq(a, nil)
	end)
end)

T.test("tmux: resolve returns nil without a current pane", function()
	with_session({ TMUX = TMUX_SOCKET }, function()
		local calls, exec = recorder()
		local a = tmux.resolve({
			{ pane_id = "%1", tab_id = "@1" },
			{ pane_id = "%2", tab_id = "@2" },
		}, exec)
		T.eq(a, nil)
		T.eq(#calls, 0)
	end)
end)

T.test("tmux: resolve returns nil when display-message fails", function()
	with_session({ TMUX = TMUX_SOCKET, TMUX_PANE = "%0" }, function()
		local a = tmux.resolve({
			{ pane_id = "%1", tab_id = "@1" },
			{ pane_id = "%2", tab_id = "@2" },
		}, fake_exec("", 1))
		T.eq(a, nil)
	end)
end)

T.test("tmux: display strips the rule's title marker", function()
	with_session({}, function()
		local row = tmux.display({
			index = "4",
			kind = "claude",
			title = "✳ Agent visibility in tmux",
		})
		T.eq(row, "4: claude - Agent visibility in tmux")
	end)
end)

T.test("tmux: display keeps a title that starts with a path", function()
	with_session({}, function()
		local row = tmux.display({
			index = "2",
			kind = "claude",
			title = "✳ /home/huggingface permissions",
		})
		T.eq(row, "2: claude - /home/huggingface permissions")
	end)
end)

T.test("tmux: display keeps a leading non-ASCII word", function()
	with_session({}, function()
		local row = tmux.display({ index = "3", kind = "claude", title = "✳ über" })
		T.eq(row, "3: claude - über")
	end)
end)

T.test("tmux: display falls back to the kind when only the marker remains", function()
	with_session({}, function()
		local row = tmux.display({ index = "5", kind = "claude", title = "✳" })
		T.eq(row, "5: claude")
	end)
end)

T.test("tmux: paste mode sets a buffer and pastes it, no Enter", function()
	local calls, exec = recorder()
	local ok = tmux.send("%3", "line1\nline2", { submit = false }, exec)
	T.ok(ok)
	T.eq(#calls, 2)
	local name = "agent-comments-" .. vim.fn.getpid()
	T.eq(calls[1], { "tmux", "set-buffer", "-b", name, "--", "line1\nline2" })
	T.eq(calls[2], { "tmux", "paste-buffer", "-p", "-r", "-d", "-b", name, "-t", "%3" })
end)

T.test("tmux: send mode appends a single Enter", function()
	local calls, exec = recorder()
	local ok = tmux.send("%3", "hi", { submit = true }, exec)
	T.ok(ok)
	T.eq(#calls, 3)
	T.eq(calls[3], { "tmux", "send-keys", "-t", "%3", "Enter" })
end)

T.test("tmux: a failed set-buffer returns err and pastes nothing", function()
	local calls, exec = recorder(1)
	local ok, err = tmux.send("%3", "hi", { submit = false }, exec)
	T.eq(ok, false)
	T.ok(err:match("boom"))
	T.eq(#calls, 1)
end)

T.test("tmux: a failed paste-buffer returns err and deletes the buffer", function()
	local calls, exec = recorder(2)
	local ok, err = tmux.send("%3", "hi", { submit = false }, exec)
	T.eq(ok, false)
	T.ok(err:match("boom"))
	T.eq(#calls, 3)
	T.eq(calls[3], { "tmux", "delete-buffer", "-b", "agent-comments-" .. vim.fn.getpid() })
end)
