local M = {}
local backends = require("agent-comments.backends")

function M.send(target, text, opts, exec)
	local backend, reason = backends.select()
	if not backend then
		return false, reason
	end
	return backend.send(target, text, opts, exec)
end

return M
