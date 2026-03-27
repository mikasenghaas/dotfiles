# Dotfiles

Configuration files for my development environment, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Toolstack

- [**Alacritty**](.config/alacritty) — terminal
- [**Ghostty**](.config/ghostty) — terminal
- [**Fish**](.config/fish) — shell
- [**Tmux**](.config/tmux) — multiplexer
- [**Neovim**](.config/nvim) — editor
- [**Vim**](.vim) — minimal vim setup (VM / vim emulation)
- [**Homebrew**](.config/brew) — package management
- [**Git**](.config/git) — version management

## Install

Requires SSH keys to be set up first (for git clone and commit signing via 1Password).

```bash
# Clone (use HTTPS if SSH keys aren't set up yet)
git clone git@github.com:mikasenghaas/dotfiles.git ~/dev/dotfiles
# git clone https://github.com/mikasenghaas/dotfiles.git ~/dev/dotfiles

# Install brew + packages
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file=~/dev/dotfiles/.config/brew/Brewfile

# Symlink everything into ~
cd ~/dev/dotfiles
stow -t ~ .
```

## Usage

Config files live in `~/dev/dotfiles/` and are symlinked to their expected locations under `~`. Editing e.g. `~/.config/nvim/init.lua` edits the repo file directly.

```bash
cd ~/dev/dotfiles
git add -A
git commit -m "update config"
git push
```
