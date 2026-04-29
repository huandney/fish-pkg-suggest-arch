set cmdline " nyancat | cmatrix && foo || bar ; baz & qux"
set sep (printf '\037')
set normalized (string replace -ar '[|&;]+' $sep -- $cmdline)
set segments (string split $sep -- $normalized)
for seg in $segments
    echo "SEG:" $seg
end
