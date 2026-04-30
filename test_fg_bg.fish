function test_bg
    set pg (command ps -o pgrp= -p %self | string trim)
    set tpg (command ps -o tpgid= -p %self | string trim)
    if test "$pg" = "$tpg"
        echo "FOREGROUND"
    else
        echo "BACKGROUND"
    end
end

test_bg
test_bg &
