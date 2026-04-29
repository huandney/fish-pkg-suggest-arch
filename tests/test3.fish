set cmdline " nyancat | cmatrix"
set sep (printf '\037')
set normalized (string replace -ar '\|\||&&|\||;|&' $sep -- $cmdline)
echo "NORM:" (string escape -- $normalized)
set segments (string split $sep -- $normalized)
echo "COUNT:" (count $segments)
