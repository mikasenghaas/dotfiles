# Alacritty

[`alacritty`](https://github.com/alacritty/alacritty) is a modern GPU-based terminal emulator that offers for easy customisation options via a settings file. 

Alacritty should have been installed from the `Brewfile` as a cask. If everything worked as expected, then you should be able to open `Alacritty.app`, which is located in the applications folder.
All settings are stored in the `alacritty.toml` file and should be automatically applied upon first opening Alacritty. It does not require any additional imports.

Most settings are related to styling the terminal (basic appearance, font, colortheme, etc.) - however, one important element are macOS specifc keybindings that map from `<Command>-<Key>` to a hex-code that tmux uses.
