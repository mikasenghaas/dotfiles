# Hammerspoon

[`hammerspoon`](https://www.hammerspoon.org/) is an automation tool for macOS. It allows to programatically interact with the operating system. I use it for custom keyboard-based window managment.

## :arrow_forward: Changing default path

By default, Hammerspoon loads the configs from `~/.hammerspoon/init.lua`. My configs are saved in `~/.config/hammerspoon/init.lua`. To change the default location of the config file, type:

```
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua
```

After restarting Hammerspoon, the configs should be loaded correctly. 

## :sparkles: Features

Hammerspoon allows me to move around my windows and have quick access to my Terminal via keyboard shortcuts. The following commands work:
The shortcuts follow vim-navigations on the top-row of the keyboard

**Window Management**

- `<HYPER>-Y`: Move window on left side of screen
- `<HYPER>-O`: Move window on right side of screen
- `<HYPER>-U`: Move window to bottom of screen
- `<HYPER>-I`: Move window to top of screen
- `<HYPER>-Enter`: Maximise current activated window (repeatedly pressing toggles between former position and maximised)

**Other**

- `<HYPER>-HJKL`: Native arrow keys
- `<HYPER>-C`: Open Alfred clipboard history

*Note: `<HYPER>` is mapped in [karabiner](https://github.com/jonas-mika/dotfiles/tree/main/.config/karabiner) to `<Ctrl>`/ `<Option>`/ `<Command>`/ `<Shift>`.*
