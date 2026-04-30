set argv "nyancat & cmatrix & tree"
set segments (string split -r -m 100 -- '&&' $argv)
set segments (string split -r -m 100 -- '||' $segments)
set segments (string split -r -m 100 -- '|' $segments)
set segments (string split -r -m 100 -- ';' $segments)
for s in $segments
    echo "SEG: $s"
end
