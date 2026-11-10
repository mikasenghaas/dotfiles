-- Local PR review: a GitHub-style PR diff in diffview, and range comments that
-- are sent to the coding agent in a sibling herdr/tmux pane.

local function git(args)
  local result = vim.system(vim.list_extend({ "git" }, args), { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end
  local out = vim.trim(result.stdout or "")
  return out ~= "" and out or nil
end

---Base branch of the current branch's PR, else the repo's default branch.
local function pr_base()
  local result = vim
    .system({ "gh", "pr", "view", "--json", "baseRefName", "--jq", ".baseRefName" }, { text = true })
    :wait()
  local base = result.code == 0 and vim.trim(result.stdout or "") or ""
  if base ~= "" and git({ "rev-parse", "--verify", "-q", "origin/" .. base }) then
    return "origin/" .. base
  end
  return git({ "symbolic-ref", "--short", "refs/remotes/origin/HEAD" }) or "origin/main"
end

---Diff merge-base(HEAD, base)..HEAD, which matches GitHub's "Files changed".
local function diffview_pr()
  local base = pr_base()
  local merge_base = git({ "merge-base", "HEAD", base })
  if not merge_base then
    vim.notify("review: no merge-base against " .. base, vim.log.levels.ERROR)
    return
  end
  vim.notify("review: diff against " .. base .. " (" .. merge_base:sub(1, 7) .. ")")
  vim.cmd("DiffviewOpen " .. merge_base)
end

local function comments(method, opts)
  return function()
    require("agent-comments")[method](opts)
  end
end

return {
  {
    "dlyongemallo/diffview-plus.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>rd", diffview_pr, desc = "Review: PR diff" },
      { "<leader>rq", "<cmd>DiffviewClose<cr>", desc = "Review: close diff" },
    },
    opts = {},
  },
  {
    -- Vendored from garrett361/dotfiles, a fork of ChmaraX/herdr-nvim (MIT).
    dir = vim.fn.stdpath("config") .. "/local_plugins/agent-comments",
    name = "agent-comments",
    -- :checkhealth finds the health module only once the plugin is on the runtimepath.
    lazy = false,
    opts = { clear_after_send = true },
    keys = {
      { "<leader>rc", comments("comment_file"), desc = "Review: comment on file" },
      { "<leader>rc", comments("comment_selection"), mode = "x", desc = "Review: comment on selection" },
      { "<leader>rl", comments("list_comments"), desc = "Review: list comments" },
      { "<leader>rs", comments("send_all", { submit = true }), desc = "Review: send comments and submit" },
      { "<leader>rS", comments("send_all", { submit = false }), desc = "Review: send comments, do not submit" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>r", group = "review" } } },
  },
}
