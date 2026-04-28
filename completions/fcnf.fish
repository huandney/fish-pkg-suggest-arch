function __fcnf_complete_layout
    set -l tokens (commandline -opc)
    contains -- fcnf_layout $tokens
end

complete -c set -n __fcnf_complete_layout -xa 'compact\t"Layout compacto (default)" classic\t"Layout clássico (uma linha por campo)" minimal\t"Layout mínimo (estilo pacman)"'
