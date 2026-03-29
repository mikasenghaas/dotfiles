# ~/.zshrc
if [ -r ~/.profile ]; then . ~/.profile; fi

# Editor
export EDITOR=vim
export VISUAL=vim

eval "$(starship init zsh)"

# bun completions
[ -s "/Users/jonas-mika/.bun/_bun" ] && source "/Users/jonas-mika/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
