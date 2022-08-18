# Tmux

[`tmux`](https://github.com/tmux/tmux/wiki) is a terminal multiplexer. It lets you switch easily between several programs in one terminal, detach them (they keep running in the background) and reattach them to a different terminal.

Tmux should have been installed from the `Brewfile`. Make sure you have installed `tmux` on your system by running

```
tmux -V
```

If this does not throw an error, tmux is installed and should be ready for use. Try to attach a new session by running

```
tmux new -s new-session
```

Look at this [cheatsheet](https://tmuxcheatsheet.com/) to kickstart your tmux usage.

## :electric_plug: Plugins

I do not use a plugin manager for tmux. Therefore, all plugins are manually installed by cloning the GitHub repository in the directry `~/.config/tmux/plugins` and are then read from the `tmux.conf` file. Follow the (manual) installation instructions of the plugins I use that are linked below to install.

1. [Resurrect](https://github.com/tmux-plugins/tmux-resurrect) to restore tmux sessions after system restart
2. [Continuum](https://github.com/tmux-plugins/tmux-continuum) to continuously save the tmux environment
3. [Prefix Highlight](https://github.com/tmux-plugins/tmux-prefix-highlight) to give a visual cue when the prefix is pressed
