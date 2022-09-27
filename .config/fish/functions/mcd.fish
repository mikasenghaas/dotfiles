function mcd -d "Make directory recurisvely and change into it on success"
    mkdir -p -- $argv && cd -- $argv
end
