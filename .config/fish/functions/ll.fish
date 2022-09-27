function ll --wraps='exa -l -g --icons' --wraps=exa_git --description 'alias ll exa_git'
  exa_git $argv; 
end
