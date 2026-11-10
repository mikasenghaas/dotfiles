# agent-comments

Annotate code the way you would in a review, then send every annotation to a coding agent running
in another pane as a single message.

## Provenance

A fork of the Lua half of [herdr-nvim](https://github.com/ChmaraX/herdr-nvim) at tag v1.0.1 by Adam
Chmara, used under the MIT License; the full text and copyright notice are in `LICENSE` next to this
file. **This code has been modified from the original.** Upstream's sidebar and file picker are
implemented in Rust and are not part of this fork. `AGENTS.md` records what diverges and why, so a
diff against upstream is not mistaken for a set of bugs.

## What it does

A visual range becomes a comment. An extmark anchors it, so the comment follows the code as the
buffer changes around it. The editor is a real buffer seeded with the quoted range, and whatever
you leave in it is what ships.

```
  visual range --> float editor --> comment store --> send --> agent pane
                        |
                        '-- extmark anchors the range to the code
```

- Comments live in memory for the session. Nothing is written to disk and nothing is restored.
- Quoted lines carry their line numbers (`  13 | code`) rather than a `>` prefix, because the
  agent has to map each line back to a position in the file, and counting down from a range header
  is the step it gets wrong.
- The comment text is sent verbatim. `prompt.item` only seeds the editor, and nothing parses the
  result back, so editing the quoted block edits what the agent sees.
- A comment exists from the moment the editor opens rather than when you save it, which is what
  keeps the range anchored while you type.

## Backends

A backend is chosen at send time. Each is asked whether its multiplexer is live and the first to
say yes wins, herdr before tmux.

```
  agents, dispatch
        |
        v
  backends.select()        first live multiplexer wins
        |
        +--> herdr --.
        +--> tmux  --'
                      |
                      v
                    exec         the only process spawn
```

- Every backend answers the same five calls: `available`, `list`, `resolve`, `display` and `send`.
  Adding one means implementing those and appending it to `M.backends`.
- `agents.lua` and `dispatch.lua` are forwarders over that selection, so all the transport code
  lives in `backends/`.
- `exec.lua` holds the only process spawn, and every other module takes an injected `exec`. That is
  what lets the tests run with no plugin manager, no multiplexer and no network.

## Layout

- `init.lua`, `commands.lua` and `health.lua` are the entry points: the Lua API, `:AgentComment`,
  and `:checkhealth agent-comments`.
- `comments.lua` stores comments and their extmarks; `ui.lua` draws every window and decoration.
- `prompt.lua` renders a comment into its quoted block; `backends/` delivers the result.

## Tests

```
cd .config/nvim/local_plugins/agent-comments
nvim --headless --noplugin -u NONE -l tests/run.lua
```

## Loading

`.config/nvim/lua/plugins/agent-comments.lua` loads this directory via a lazy.nvim `dir =` spec, so
it is never written to `lazy-lock.json`, never a `Lazy! clean` candidate, and skipped by
`Lazy! restore`.
