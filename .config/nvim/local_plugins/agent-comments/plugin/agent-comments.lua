-- Registers the :AgentComment user command (deferred require). setup() re-registers
-- idempotently, so eager and lazy loads both end up with exactly one command.
require("agent-comments.commands").register()
