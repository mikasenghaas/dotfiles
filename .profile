# .profile

# Aliases
alias c=clear
alias g=git
alias ll="ls -al"
alias drive="cd ~/Google\ Drive/My\ Drive"
alias config="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias whatsmyip="dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com"

# Paths
PATH=$PATH:/opt/homebrew/bin
PATH=$PATH:~/.local/bin

# Env (needed for r)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Pyenv [virtualenv]
export pyenv_root="$home/.pyenv"
command -v pyenv >/dev/null || export path="$pyenv_root/bin:$path"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# SSH
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)"
fi

# List of SSH keys to add
SSH_KEYS=("~/.ssh/id_rsa" "~/.ssh/github-personal ~/.ssh/prime")

# Add each key to ssh-agent
for key in "${SSH_KEYS[@]}"; do
  [ -f "$key" ] && ssh-add "$key"
done

echo "Loaded .profile"
