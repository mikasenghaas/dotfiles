# ~/.config/fish/config.fish

# disable fish greeting
set fish_greeting ""

# color theme
fish_config theme choose "Just a Touch"

# abbreviations
abbr -a c clear
abbr -a n nvim
abbr -a gst "git status"
abbr -a gd "git diff"
abbr -a ga "git add"
abbr -a gaa "git add ."
abbr -a gc "git commit"
abbr -a gcm 'git commit -m'
abbr -a gpl "git pull"
abbr -a gps "git push"
abbr -a gb "git branch"
abbr -a gco "git checkout"
abbr -a gl "git log"
abbr -a glp "git logpretty"
abbr -a glg "git loggraph"

# aliases
alias python='uvx --with numpy,torch,pandas,datasets,transformers python'
alias ipython='uvx --with numpy,torch,pandas,datasets,transformers ipython'

# editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# vim mode
function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
end

# paths
fish_add_path /bin ~/.local/bin
fish_add_path /opt/homebrew/bin
fish_add_path ~/dev/scripts
fish_add_path ~/.bun/bin

# fzf
eval "$(fzf --fish)"

# ssh
eval (ssh-agent -c) >/dev/null 2>&1
set SSH_KEYS ~/.ssh/primeintellect ~/.ssh/github >/dev/null 2>&1
for key in $SSH_KEYS
    ssh-add $key >/dev/null 2>&1
end
fish_add_path $HOME/.local/bin
test -f ~/.op/plugins.sh; and source ~/.op/plugins.sh
