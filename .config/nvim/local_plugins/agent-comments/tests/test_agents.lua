local agents = require("agent-comments.backends.herdr")

local fixture = vim.json.encode({
	id = "cli:agent:list",
	result = {
		agents = {
			{
				pane_id = "wA:p1",
				workspace_id = "wA",
				agent = "pi",
				agent_status = "idle",
				cwd = "/tmp/proj-a",
				terminal_title = "π - proj-a",
			},
			{
				pane_id = "wB:p2",
				workspace_id = "wB",
				agent = "claude",
				agent_status = "working",
				cwd = "/tmp/proj-b",
			},
		},
	},
})

local same_workspace_fixture = vim.json.encode({
	id = "cli:agent:list",
	result = {
		agents = {
			{
				pane_id = "wA:p1",
				workspace_id = "wA",
				agent = "pi",
				agent_status = "idle",
				cwd = "/tmp/proj-a",
				terminal_title = "π - proj-a",
			},
			{
				pane_id = "wA:p2",
				workspace_id = "wA",
				agent = "claude",
				agent_status = "working",
				cwd = "/tmp/proj-b",
			},
		},
	},
})

local statusless_fixture = vim.json.encode({
	id = "cli:agent:list",
	result = {
		agents = {
			{
				pane_id = "wA:p1",
				workspace_id = "wA",
				agent = "pi",
				cwd = "/tmp/proj-a",
				terminal_title = "π - proj-a",
			},
		},
	},
})

local function fake_exec(out, code)
	return function(_)
		return { code = code or 0, stdout = out, stderr = "" }
	end
end

local function with_workspace(id, fn)
	local previous = vim.env.HERDR_WORKSPACE_ID
	vim.env.HERDR_WORKSPACE_ID = id
	local ok, err = pcall(fn)
	vim.env.HERDR_WORKSPACE_ID = previous
	if not ok then
		error(err, 0)
	end
end

T.test("agents: available reports the unset workspace id", function()
	with_workspace(nil, function()
		local ok, reason = agents.available()
		T.eq(ok, false)
		T.ok(reason and reason:find("HERDR_WORKSPACE_ID", 1, true), "reason names the env var")
	end)
end)

T.test("agents: available is true inside a session", function()
	with_workspace("wA", function()
		T.eq(agents.available(), true)
	end)
end)

T.test("agents: list without a session returns an error, not a widened list", function()
	with_workspace(nil, function()
		local list, err = agents.list(fake_exec(fixture))
		T.eq(list, nil)
		T.ok(err and err:match("session"), "error mentions the missing session")
	end)
end)

T.test("agents: parses list and normalizes fields", function()
	with_workspace("wA", function()
		local list, err = agents.list(fake_exec(same_workspace_fixture))
		T.eq(err, nil)
		T.eq(#list, 2)
		local by_pane = {}
		for _, agent in ipairs(list) do
			by_pane[agent.pane_id] = agent
		end
		T.eq(by_pane["wA:p1"].kind, "pi")
		T.eq(by_pane["wA:p1"].status, "idle")
		T.eq(by_pane["wA:p1"].title, "π - proj-a")
		T.eq(by_pane["wA:p2"].title, "claude") -- falls back to kind
	end)
end)

T.test("agents: sorts same-workspace agents by title", function()
	with_workspace("wA", function()
		local list = agents.list(fake_exec(same_workspace_fixture))
		T.eq(list[1].pane_id, "wA:p2")
		T.eq(list[1].title, "claude")
		T.eq(list[2].pane_id, "wA:p1")
		T.eq(list[2].title, "π - proj-a")
	end)
end)

T.test("agents: current workspace excludes other workspaces", function()
	with_workspace("wB", function()
		local list = agents.list(fake_exec(fixture))
		T.eq(#list, 1)
		T.eq(list[1].pane_id, "wB:p2")
	end)
end)

T.test("agents: status stays nil when the CLI omits it", function()
	with_workspace("wA", function()
		local list = agents.list(fake_exec(statusless_fixture))
		T.eq(#list, 1)
		T.eq(list[1].status, nil)
	end)
end)

T.test("agents: CLI failure returns err", function()
	with_workspace("wA", function()
		local list, err = agents.list(fake_exec("", 1))
		T.eq(list, nil)
		T.ok(err and err:match("herdr"))
	end)
end)

T.test("agents: unparseable JSON returns err", function()
	with_workspace("wA", function()
		local list, err = agents.list(fake_exec("not json"))
		T.eq(list, nil)
		T.ok(err and err:match("unparseable"))
	end)
end)

T.test("agents: resolve returns the lone workspace agent", function()
	with_workspace("wA", function()
		local a = agents.resolve({ { pane_id = "wA:p1", tab_id = "wA:t1" } })
		T.eq(a.pane_id, "wA:p1")
	end)
end)

T.test("agents: resolve picks the single agent in the current tab", function()
	with_workspace("wA", function()
		local previous = vim.env.HERDR_TAB_ID
		vim.env.HERDR_TAB_ID = "wA:t2"
		local a = agents.resolve({
			{ pane_id = "wA:p1", tab_id = "wA:t1" },
			{ pane_id = "wA:p2", tab_id = "wA:t2" },
		})
		vim.env.HERDR_TAB_ID = previous
		T.eq(a.pane_id, "wA:p2")
	end)
end)

T.test("agents: resolve returns nil when the tab is ambiguous", function()
	with_workspace("wA", function()
		local previous = vim.env.HERDR_TAB_ID
		vim.env.HERDR_TAB_ID = "wA:t1"
		local a = agents.resolve({
			{ pane_id = "wA:p1", tab_id = "wA:t1" },
			{ pane_id = "wA:p2", tab_id = "wA:t1" },
		})
		vim.env.HERDR_TAB_ID = previous
		T.eq(a, nil)
	end)
end)

T.test("agents: resolve returns nil when no tab context disambiguates", function()
	with_workspace("wA", function()
		local previous = vim.env.HERDR_TAB_ID
		vim.env.HERDR_TAB_ID = nil
		local a = agents.resolve({
			{ pane_id = "wA:p1", tab_id = "wA:t1" },
			{ pane_id = "wB:p2", tab_id = "wB:t1" },
		})
		vim.env.HERDR_TAB_ID = previous
		T.eq(a, nil)
	end)
end)

T.test("agents: display row leads with agent kind", function()
	with_workspace("wA", function()
		local row =
			agents.display({ kind = "pi", title = "π - a", status = "idle", cwd = "/x/y/proj" })
		T.eq(row, "pi · idle · proj")
	end)
end)

T.test("agents: display omits the status segment when status is nil", function()
	with_workspace("wA", function()
		local row = agents.display({ kind = "pi", title = "π - a", cwd = "/x/y/proj" })
		T.eq(row, "pi · proj")
	end)
end)
