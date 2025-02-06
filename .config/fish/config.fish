# ~/.config/fish/config.fish

# Disable fish greeting 
set fish_greeting ""

# Color theme
fish_config theme choose "Just a Touch"

# Abbreviations
abbr -a c clear
abbr -a n nvim
abbr -a gst "git status"
abbr -a gd "git diff"
abbr -a ga "git add"
abbr -a gc "git commit"
abbr -a gpl "git pull"
abbr -a gps "git push"
abbr -a gb "git branch"
abbr -a gco "git checkout"
abbr -a gl "git log"
abbr -a glp "git prettylog"
abbr -a glg "git graphlog"

# Aliases
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Vim mode
function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
end

# Paths
fish_add_path /bin ~/bin ~/.local/bin
fish_add_path /opt/homebrew/bin
fish_add_path ~/scripting

# Java
set CLASSPATH .
alias java8 "set -x JAVA_HOME (/usr/libexec/java_home -v 1.8.0); java -version"
alias java17 "set -x JAVA_HOME (/usr/libexec/java_home -v 17); java -version"
alias java19 "set -x JAVA_HOME (/usr/libexec/java_home -v 19); java -version"
set -x JAVA_HOME (/usr/libexec/java_home)
fish_add_path /Library/Java

# FZF
eval "$(fzf --fish)"

# SSH
eval (ssh-agent -c) >/dev/null 2>&1
set SSH_KEYS ~/.ssh/id_rsa ~/.ssh/github-personal >/dev/null 2>&1
for key in $SSH_KEYS
    ssh-add $key >/dev/null 2>&1
end
uv generate-shell-completion fish | source
uvx --generate-shell-completion fish | source
