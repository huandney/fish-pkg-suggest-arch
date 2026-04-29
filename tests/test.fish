set cmdline 'echo "foo | bar "'
set sep (printf '\037')
set normalized (string replace -ar '\|\||&&|\||;|&' $sep -- $cmdline)
set segments (string split $sep -- $normalized)

for seg in $segments
    set tok (string split -m 1 " " (string trim -- $seg))[1]
    echo "Segment: $seg -> Token: $tok"
    if string match -qr '^[A-Za-z_][A-Za-z0-9_+.-]*$' -- $tok
        echo "Valid command format: $tok"
    end
end
