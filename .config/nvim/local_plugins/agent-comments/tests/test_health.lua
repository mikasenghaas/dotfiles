local health = require("agent-comments.health")

-- Externals are injected so the result does not depend on whether a multiplexer CLI happens
-- to be installed, or on whether the suite is run from inside a session of one.
local function report(found, backend, reason)
	return health._report({
		executable = function()
			return found and 1 or 0
		end,
		backend = function()
			return backend, reason
		end,
	})
end

local herdr = { name = "herdr", binary = "herdr" }

T.test("health: a missing herdr CLI is an error", function()
	local out = report(false, herdr)
	T.eq(out[1][1], "error")
	T.ok(out[1][2]:find("PATH", 1, true), "the message names PATH")
	T.ok(out[1][3]:find("install herdr", 1, true), "the advice says to install herdr")
	T.eq(out[2][1], "ok")
	T.eq(out[2][3], nil, "an ok entry carries no advice")
end)

T.test("health: a missing session warns rather than errors, and carries the reason", function()
	local out = report(true, nil, "not in a herdr session (HERDR_WORKSPACE_ID is unset)")
	T.eq(out[2][1], "warn")
	T.eq(out[2][2], "not in a herdr session (HERDR_WORKSPACE_ID is unset)")
	T.ok(out[2][3]:find("comments still work", 1, true), "the advice says commenting still works")
end)

T.test("health: with no backend both entries warn and the reason names each multiplexer", function()
	local combined = "not in a herdr session (HERDR_WORKSPACE_ID is unset); "
		.. "not in a tmux session (TMUX is unset)"
	local out = report(true, nil, combined)
	T.eq(#out, 2)
	T.eq(out[1][1], "warn")
	T.eq(out[2][1], "warn")
	T.ok(out[2][2]:find("herdr", 1, true), "the reason names herdr")
	T.ok(out[2][2]:find("tmux", 1, true), "the reason names tmux")
end)
