local M = {}
local backends = require("agent-comments.backends")

function M.available()
	local backend, reason = backends.select()
	if not backend then
		return false, reason
	end
	return backend.available()
end

function M.list(exec)
	local backend, reason = backends.select()
	if not backend then
		return nil, reason
	end
	return backend.list(exec)
end

-- The lone candidate is answered before any backend is selected, so the common
-- one-agent path never depends on the ambient environment or spawns a process.
-- Every backend returns list[1] for a single-entry list anyway.
function M.resolve(list, exec)
	if #list == 1 then
		return list[1]
	end
	local backend = backends.select()
	if not backend then
		return nil
	end
	return backend.resolve(list, exec)
end

function M.display(agent)
	local backend = backends.select()
	if not backend then
		return agent.title or agent.kind or "agent"
	end
	return backend.display(agent)
end

return M
