# .profile

# aliases
alias c=clear
alias g=git
alias ll="ls -al"
alias drive="cd ~/Google\ Drive/My\ Drive"
alias config="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias whatsmyip="dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com"

# paths 
PATH=$PATH:/opt/homebrew/bin
PATH=$PATH:~/.local/bin

# env (needed for r)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# pyenv [virtualenv]
export pyenv_root="$home/.pyenv"
command -v pyenv >/dev/null || export path="$pyenv_root/bin:$path"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
