set local_miss nyancat cmatrix
set miss_cmds
for tok in $local_miss
    echo "Checking $tok"
    set -l matches (pkgfile -b $tok 2>/dev/null)
    echo "Matches for $tok: $matches"
    test (count $matches) -eq 0; and continue
    set -a miss_cmds $tok
end
echo "miss_cmds: $miss_cmds"
