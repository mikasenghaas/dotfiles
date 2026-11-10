local backends = require("agent-comments.backends")
local agents = require("agent-comments.agents")

-- TMUX_PANE travels with TMUX rather than being a separate knob, so a suite run from
-- inside tmux cannot leak the real one into a case that means to have no tmux session.
local function with_env(workspace, tmux, fn)
	local previous_workspace, previous_tmux = vim.env.HERDR_WORKSPACE_ID, vim.env.TMUX
	local previous_pane = vim.env.TMUX_PANE
	vim.env.HERDR_WORKSPACE_ID = workspace
	vim.env.TMUX = tmux
	vim.env.TMUX_PANE = tmux and "%0" or nil
	local ok, err = pcall(fn)
	vim.env.HERDR_WORKSPACE_ID, vim.env.TMUX = previous_workspace, previous_tmux
	vim.env.TMUX_PANE = previous_pane
	if not ok then
		error(err, 0)
	end
end

T.test("backends: herdr wins when both multiplexers are available", function()
	with_env("wA", "/tmp/tmux-test/default,1,0", function()
		T.eq(backends.select().name, "herdr")
	end)
end)

T.test("backends: tmux is selected when it is the only session", function()
	with_env(nil, "/tmp/tmux-test/default,1,0", function()
		T.eq(backends.select().name, "tmux")
	end)
end)

T.test("backends: with no session the reason names every backend tried", function()
	with_env(nil, nil, function()
		local backend, reason = backends.select()
		T.eq(backend, nil)
		T.ok(reason:find("HERDR_WORKSPACE_ID", 1, true), "the reason names the herdr env var")
		T.ok(reason:find("TMUX", 1, true), "the reason names the tmux env var")
	end)
end)

T.test("backends: the lone candidate resolves without a backend or a process", function()
	with_env(nil, nil, function()
		local a = agents.resolve({ { pane_id = "%1", tab_id = "@1" } }, function()
			error("resolve must not run a command for a single candidate")
		end)
		T.eq(a.pane_id, "%1")
	end)
end)

T.test("backends: list surfaces the selector's reason when nothing is available", function()
	with_env(nil, nil, function()
		local list, err = agents.list(function()
			error("list must not run a command without a backend")
		end)
		T.eq(list, nil)
		T.ok(err:find("HERDR_WORKSPACE_ID", 1, true), "the error names the herdr env var")
		T.ok(err:find("TMUX", 1, true), "the error names the tmux env var")
	end)
end)
