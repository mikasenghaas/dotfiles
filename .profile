# ~/.profile

# aliases
alias c=clear
alias g=git
alias ll="ls -al"
alias config="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# paths
PATH=$PATH:/opt/homebrew/bin
PATH=$PATH:~/.local/bin

# ssh
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)"
fi

SSH_KEYS=("~/.ssh/github ~/.ssh/primeintellect")
for key in "${SSH_KEYS[@]}"; do
  [ -f "$key" ] && ssh-add "$key"
done
