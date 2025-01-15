# Tmux

[`tmux`](https://github.com/tmux/tmux/wiki) is a terminal multiplexer. It lets you switch easily between several programs in one terminal, detach them (they keep running in the background) and reattach them to a different terminal.

`tmux` should have been installed from the `Brewfile`. Check the current version by running

```
tmux -V
```

If this does not throw an error, tmux is installed and should be ready for use. Try to attach a new session by running

```
tmux new -s new-session
```

Look at this [cheatsheet](https://tmuxcheatsheet.com/) to kickstart your tmux usage.
