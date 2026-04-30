function fish_command_not_found
    echo "called handler for $argv"
    read -p "echo 'prompt> '" ans
    echo "got $ans"
end
