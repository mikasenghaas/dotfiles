# config.fish
#  configurations for fish shell
# by: mika senghaas

# disable fish greeting
set fish_greeting ""

# set term
set -gx TERM xterm-256color

### aliases

# nav
alias . "cd .."
alias .. "cd ../.."
alias ... "cd ../../.."
alias root "cd /"
alias home "cd ~"
alias desk "cd ~/Desktop"
alias down "cd ~/Downloads"
alias drive='cd ~/Google\ Drive/My\ Drive'
alias config "cd ~/.config"
alias back "cd -"
alias itu "cd ~/programming/itu"

# apps
alias fm "vifm ."
alias of "open ."

# ssh
alias hpc "ssh jsen@hpc.itu.dk"

# miscellaneous
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias whatsmyip="dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com"
alias c clear

# git
alias g git

if type -q exa
  alias ll "exa -l -g --icons"
  alias lla "ll -a"
end

# vi mode
function fish_user_key_bindings
  fish_default_key_bindings -M insert
  fish_vi_key_bindings --no-erase insert
end

# paths
set -gx EDITOR nvim

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

# NodeJS
set -gx PATH node_modules/.bin $PATH

# plugins configs
source ~/.config/fish/plugins/hydro.rc.fish
source ~/.config/fish/plugins/fzf.rc.fish
source ~/.config/fish/plugins/vi.rc.fish

# add path
fish_add_path /opt/homebrew/bin

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /Users/jonas-mika/opt/anaconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<

