function mld -d "Move last downloaded file into current working directory"
    command mv ~/Downloads/(ls -t -A ~/Downloads/ | head -1) .
end
