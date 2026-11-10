local M = {}

-- The decision, separated from vim.health so it can be tested with injected externals.
function M._report(env)
	env = env or {}
	local executable = env.executable or vim.fn.executable
	local select_backend = env.backend or require("agent-comments.backends").select
	local out = {}
	local backend, reason = select_backend()
	-- A missing session is a warning, not an error: commenting works without one, only
	-- sending needs it. With no backend there is also no binary to look for.
	if not backend then
		out[#out + 1] = { "warn", "no supported multiplexer detected" }
		out[#out + 1] = { "warn", reason, "comments still work; sends will report this error" }
		return out
	end
	if executable(backend.binary) == 1 then
		out[#out + 1] = { "ok", backend.binary .. " found on PATH" }
	else
		out[#out + 1] = {
			"error",
			backend.binary .. " not found on PATH",
			"install " .. backend.binary .. "; without it every send fails at dispatch time",
		}
	end
	out[#out + 1] = { "ok", backend.name .. " session detected" }
	return out
end

function M.check()
	vim.health.start("agent-comments")
	for _, entry in ipairs(M._report()) do
		vim.health[entry[1]](entry[2], entry[3] and { entry[3] } or nil)
	end
end

return M
