# Brew

[`brew`](https://brew.sh/) is a package manager for macOS that I use to install and update applications (called casks) and other pieces of software that I use on a day-to-day basis.

Before proceeding, download `brew` using this command:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

To dump the current configuration run:

```bash
brew bundle dump --describe --brews --casks --taps --file ~/.config/brew/Brewfile
```

To install the current configuration run:

```bash
brew bundle --file=~/.config/brew/Brewfile
```
