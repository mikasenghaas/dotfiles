# agent-comments: divergences from upstream

This is a fork of the Lua half of [herdr-nvim](https://github.com/ChmaraX/herdr-nvim) at tag v1.0.1.
Every difference below is deliberate. Diff against the reference clone at
`~/github/garrett361/herdr-nvim` before assuming something here is a bug, and add to this list
rather than making an unrecorded change.

Entries describe the current state, not the order things happened in. That history is in
`git log`.

- Renamed throughout: module `herdr-nvim` to `agent-comments`, command `:Herdr` to `:AgentComment`,
  highlight groups `HerdrNvimComment{Sign,Text,Line}` to `AgentComments{Sign,Text,Line}`.
- Reformatted with this repo's stylua config, tabs at 100 columns.
- The plugin defines no keymaps. `M.config.prefix`, `M.config.keymaps` and the guard that skipped
  already-mapped keys are gone, and the maps are declared in the user's lazy spec instead.
  `M.statusline()` was removed as unused.
- `agents.available()` gates `agents.list()`: a missing workspace is an error rather than a
  candidate list widened to every agent in every workspace. An agent's `status` is optional, since a
  multiplexer without an agent supervisor reports none, and `agents.display()` omits that segment
  when it is absent.
- Decorations live in their own extmark namespace, separate from the one tracking comment ranges,
  so a query of either namespace means exactly one thing.
- The prompt is a `N comment(s):` count line followed by the items. Upstream's header asserted a
  review intent the individual comments contradict, and its format note explained a convention
  `git blame` and `bat` already share. The count leads because a truncated paste loses the end of
  the message, which is where the old footer put it.
- An item is a column-zero `path:range` header, the quoted code with a line number on every line up
  to a 200-line cap, a blank line, then the comment text as typed. Buffers with unwritten changes
  are marked `[unsaved]`.
- The transport is split into `backends/herdr.lua` and `backends/tmux.lua` behind a selector taking
  the first multiplexer whose session is live, herdr before tmux; `agents` and `dispatch` forward
  through it. The tmux backend lists the panes of the current session, keeps those whose title or
  current command matches a configured agent rule (by default claude, codex and prime-agent,
  matched on the same process names as `tmux-agent-lib.sh` but independent of it; supporting
  another harness is one more `agents` entry), resolves to the single candidate sharing the
  current window, and delivers through `set-buffer` plus `paste-buffer` so a multi-line prompt
  arrives as one paste rather than one submitted line per newline. The paste is flagged `-p -r -d`
  and deliberately not `-S`, which tmux 3.7 added to disable the `vis(3)` escaping it introduced in
  the same release so that a buffer containing the bracket end sequence cannot break out of the `-p`
  bracketed paste. The prompt quotes arbitrary source, so that escaping is wanted, and it is a flag
  tmux 3.6 and earlier reject outright.
- There is no per-comment git context and no `git` spawn. The absolute path in each item header
  already identifies the repo, and the branch is one `git rev-parse` away in a tree the agent is
  already sitting in.
- The comment list restores the code window's buffer and view on cancel; `<CR>` jumps, `e` edits,
  `dd` deletes. Highlights are re-applied on `ColorScheme`, which upstream let wipe them, and
  `:checkhealth agent-comments` was added.
- Comment text is typed into a scratch float and committed with `:w`, in place of the single-line
  `vim.ui.input`, so a comment can run to several paragraphs and be edited before it is sent. The
  buffer is `acwrite` with a counter-based name, since `:w` on a `nofile` or unnamed buffer fails
  before `BufWriteCmd` fires; `bufhidden` is `wipe` and `BufWipeout` is the one teardown funnel.
  `q`, `<Esc>` and `<C-c>` are deliberately unbound, the last because it is the habitual way out
  of insert mode; `:q` cancels. `on_done` fires on every exit path, with `nil` on a cancel.
  The buffer is `markdown` so the user's markdown snippets, keymaps and highlighting apply.
  `textwidth` is set to 0 after the filetype, which a markdown hook may raise, so typed text is
  never hard-wrapped; the float soft-wraps instead. `foldenable` is off, since the float inherits
  the code window's fold settings.
- `init.comment_range` anchors the comment when the editor opens, not when it is written:
  `comments.add(bufnr, start, end, nil)` records a draft, and the callback either edits the text in
  or deletes the draft. The editor can be left with `<C-w>w` to go read the code, so the window
  between picking the lines and writing the text is unbounded; plain line numbers held across it
  would attach the finished comment to whatever has since moved under them. `comments.list` skips
  drafts, so one reaches neither the prompt nor the comment list, while `comments.get` and
  `comments.snippet` still resolve it. A draft is decorated with the rail alone.
- There is one kind of comment. Visual `<leader>zc` seeds the editor with the rendered item for the
  selection, and `prompt.format` emits what the buffer holds as typed. Normal-mode `<leader>zc`
  calls `comment_file()` instead: a whole-file comment whose item header is the bare path, with no
  range and no quote. It is anchored at line 1 for tracking and sorting but decorated with the
  callout alone, since a rail on line 1 would claim the comment is about that line. The cost is
  accepted knowingly: every comment is a snapshot, so one written before a large edit quotes and
  cites the file as it was. `ui.summary` is the block's line count, since the block is freely
  editable and any guess at which line carries the annotation would eventually point at the wrong
  one.
