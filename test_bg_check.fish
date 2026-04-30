function f
    set pg (command ps -o pgrp= -p %self | string trim)
    set tpg (command ps -o tpgid= -p %self | string trim)
    if test "$pg" != "$tpg"
        echo "BACKGROUND"
    else
        echo "FOREGROUND"
    end
end
