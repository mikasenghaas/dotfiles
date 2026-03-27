# ~/.bashrc
if [ -r ~/.profile ]; then . ~/.profile; fi

# editor
export EDITOR=vim
export VISUAL=vim

PS1="\w \$ "

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
