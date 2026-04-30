function test_preexec --on-event fish_preexec
    echo "Inside preexec"
    set -l stty_state (stty -g)
    stty sane
    # simulated interactive prompt
    read -P "Type something: " var
    echo "You typed: $var"
    stty $stty_state
end
echo "Running dummy"
