# Dofiles

![last-commit-badge](https://img.shields.io/github/last-commit/mikasenghaas/dotfiles)

This is a repository to store all settings of my current development environment. 
Feel free to take inspiration.

## :hammer: Toolstack 

This is my current toolstack with all configurations as of 08/2024:

- [**Alacritty**](https://github.com/mikasenghaas/dotfiles/tree/main/.config/alacritty) as my primary **terminal**
- [**Tmux**](https://github.com/mikasenghaas/dotfiles/tree/main/.config/tmux) for **multiplexing**
- [**Fish**](https://github.com/mikasenghaas/dotfiles/tree/main/.config/fish) as my primary **shell**
- [**Cursor**](https://cursor.ai) as my primary **editor**
- [**Neovim**](https://github.com/mikasenghaas/dotfiles/tree/main/.config/nvim) as my secondary **editor**
- [**Vim**](https://github.com/mikasenghaas/dotfiles/tree/main/.vim) for a minimal vim setup (used for Vim emulations and on VMs)
- [**Homebrew**](https://github.com/mikasenghaas/dotfiles/tree/main/.config/brew) for macOS package management
- [**Karabiner**](https://github.com/mikasenghaas/dotfiles/tree/main/.config/karabiner) for custom key-bindings

## :battery: Install

Follow these steps to install the full development environment.

### Clone this repository 

Fire up the natively installed Terminal on your new machine (`Terminal.app` on macOS) and write into the default shell (`zsh` on newer macOS version) config file (so `~/.zshrc`) to set the alias for the bare repo:

```bash
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

Then, clone this repository in your home directory (`/Users/<your-username>`) by running this command

```bash
git clone --bare https://github.com/mikasenghaas/dotfiles $HOME/.dotfiles
```

Checkout the contents of the bare repo by running `config checkout`. This might lead to an error, if the contents of the git repo are overwriting files that already exist on your system. 
Try this command to move all conflicting files into a backup folder:

```bash
mkdir -p .config-backup && \
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}
```

Rerun, `config checkout` to check that all files are correctly cloned from git. 
Finally, set the `status.showUntrackedFiles` flag to `no` by running this command to ignore untracked files from being shown in `git status`

```bash
git config --local status.showUntrackedFiles no
```

:partying_face: Done, all configs should be on your system in the correct location!

### Install brew

*Detailed infos [here](https://github.com/mikasenghaas/dotfiles/tree/main/.config/brew)*

Download the macOS pacakage manager `homebrew` using

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install all software with

```bash
brew bundle --file=~/.config/brew/Brewfile
```

### Further Configurations

Visit all the README files from the above listed applications and follow any further installation instructions (if they exist).
