local M = {}
local herdr = require("agent-comments.backends.herdr")
local tmux = require("agent-comments.backends.tmux")

M.backends = { herdr, tmux }

function M.select()
	local reasons = {}
	for _, backend in ipairs(M.backends) do
		local ok, reason = backend.available()
		if ok then
			return backend
		end
		reasons[#reasons + 1] = reason
	end
	return nil, table.concat(reasons, "; ")
end

return M
