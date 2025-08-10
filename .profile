# ~/.profile

# Aliases
alias c=clear
alias g=git
alias ll="ls -al"
alias config="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# Paths
PATH=$PATH:/opt/homebrew/bin
PATH=$PATH:~/.local/bin

# Env (needed for r)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# SSH
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)"
fi

# List of SSH keys to add
SSH_KEYS=("~/.ssh/github ~/.ssh/primeintellect")

# Add each key to ssh-agent
for key in "${SSH_KEYS[@]}"; do
  [ -f "$key" ] && ssh-add "$key"
done
