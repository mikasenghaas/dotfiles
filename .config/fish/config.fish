# config.fish
#  configurations for fish shell
# by: mika senghaas

set fish_greeting ""

# aliases
# -------

alias c clear
alias g git
alias n nvim
alias t tmux
alias ll="lsd -l"
alias lla="lsd -la"
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias whatsmyip="dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com"

# vim-mode
# --------

function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
end

# paths
# -----

# brew
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path /opt/homebrew/opt/openjdk/bin

# editor
set -gx EDITOR nvim

# misc
set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

set -gx PATH node_modules/.bin $PATH

# java
set CLASSPATH .
alias java8 "set -x JAVA_HOME (/usr/libexec/java_home -v 1.8.0); java -version"
alias java17 "set -x JAVA_HOME (/usr/libexec/java_home -v 17); java -version"
alias java19 "set -x JAVA_HOME (/usr/libexec/java_home -v 19); java -version"
set -x JAVA_HOME (/usr/libexec/java_home)
fish_add_path /Library/Java

# python
pyenv init - | source
status --is-interactive; and pyenv virtualenv-init - | source

# r
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8


# plugins configs
source ~/.config/fish/plugins/hydro.rc.fish
source ~/.config/fish/plugins/vi.rc.fish

# fzf
# ---
eval "$(fzf --fish)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/jonas-mika/Downloads/google-cloud-sdk/path.fish.inc' ]
    . '/Users/jonas-mika/Downloads/google-cloud-sdk/path.fish.inc'
end
