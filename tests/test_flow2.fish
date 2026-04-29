#!/usr/bin/env fish
# Phase-2 standalone: takes a hand-crafted local_miss list, runs only the
# pkgfile resolution loop. Useful for debugging the I/O path in isolation.
# Run from repo root: fish tests/test_flow2.fish

# Simulate nyancat | cmatrix where BOTH are missing
set local_miss nyancat cmatrix
set miss_cmds
set sep (printf '\037')
for tok in $local_miss
    set matches (pkgfile -b $tok 2>/dev/null)
    test (count $matches) -eq 0; and continue
    set full $matches[1]
    set -a miss_cmds $tok
    set -a miss_repos (string split "/" $full)[1]
    set -a miss_pkgs (string split "/" $full)[2]
    set -a miss_matches (string join $sep $matches)
end
echo "miss_cmds count: "(count $miss_cmds)
