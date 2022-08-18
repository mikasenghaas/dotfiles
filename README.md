# Dofiles

This is a repository to store all settings of my current development environment. 
Feel free to take inspiration.

## :hammer: Toolstack 

The full list fo applications and software I use every day.

- [**alacritty**](https://github.com/jonas-mika/dotfiles/tree/main/.config/alacritty) as primary terminal
- [**fish**](https://github.com/jonas-mika/dotfiles/tree/main/.config/fish) as primary shell
- [**nvim**](https://github.com/jonas-mika/dotfiles/tree/main/.config/nvim) as primary editor 
- [**tmux**](https://github.com/jonas-mika/dotfiles/tree/main/.config/tmux) for managing terminal sessions
- [**vim**]() as secondary (outdated) editor
- [**vifm**](https://github.com/jonas-mika/dotfiles/tree/main/.config/vifm) for vim-based file managment inside the terminal
- [**hammerspoon**](https://github.com/jonas-mika/dotfiles/tree/main/.config/hammerspoon) for vim-based window managment
- [**karabiner**](https://github.com/jonas-mika/dotfiles/tree/main/.config/karabiner) for custom key-bindings
- [**brew**](https://github.com/jonas-mika/dotfiles/tree/main/.config/brew) for macOS package management

## :battery: Install

Follow these steps to install the full development environment.

### 1. Cloning the repo

First, clone this repository in your home directory (`/Users/<your-username>`) by running this command

```
git clone --bare <url> $HOME
```

Set the `status.showUntrackedFiles` flag to `no` by running this command to ignore untracked files from being shown in `git status`

```
git config --local status.showUntrackedFiles no
```


### 2. Brew

Install `brew` by following the instructions in the [README]()

### 3. Alacritty & Shell

Open up alacritty - the terminal. All terminal settings should be read automatically and work with no further installs. The same goes for `zsh`.

### 4. Neovim & Vim

Now it's time to configure the editors. 

Neovim was installed as part of the `Brewfile`, but uses some additional plugins. Follow the instructions in the [README]() to correctly install all plugins.

Vim is a legacy editor, that I sometimes use if I want a minimal vim version. It does not require any additional plugins, so just go ahead and type `vim` and you are ready to go.

### 5. Vifm

### 6. Hammerspoon & Karabiner

