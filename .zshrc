# ~/.zshrc
if [ -r ~/.profile ]; then . ~/.profile; fi

git_branch() {
  git rev-parse --abbrev-ref HEAD 2> /dev/null
}

PS1='%1~ %# '
