# Brew

[`brew`](https://brew.sh/) is a package manager for macOS that I use to install and update applications (called casks) and other pieces of software that I use on a day-to-day basis.

Before proceding, download `brew` using this command:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
*Link modified: 18/08/22*

To install my personal selection of casks, formulas, fonts and more run the following command.

```
brew bundle --file=~/.config/brew/Brewfile
```
