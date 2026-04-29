set cmdline "nyancat | cmatrix"
set sep (printf '\037')
set normalized (string replace -ar '\|\||&&|\||;|&' $sep -- $cmdline)
set segments (string split $sep -- $normalized)
set keywords if else for while function begin end switch case not and or command builtin exec time set status return break continue test true false read echo printf
set seen
set local_miss

for seg in $segments
    set trimmed (string trim -- $seg)
    test -z "$trimmed"; and continue
    set tok (string split -m 1 ' ' -- $trimmed)[1]
    test -z "$tok"; and continue
    string match -qr '^[A-Za-z_][A-Za-z0-9_+.-]*$' -- $tok; or continue
    contains -- $tok $keywords; and continue
    contains -- $tok $seen; and continue
    set -a seen $tok
    type -q $tok; and continue
    set -a local_miss $tok
end

echo "LOCAL MISS: $local_miss"
