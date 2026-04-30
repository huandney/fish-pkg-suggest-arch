function __fcnf_complete_layout_legacy
    set -l tokens (commandline -opc)
    contains -- fcnf_layout $tokens
end

complete -c set -n __fcnf_complete_layout_legacy -xa 'compact\t"Layout compacto (default)" classic\t"Layout clássico (uma linha por campo)" minimal\t"Layout mínimo (estilo pacman)"'

# fcnf — main entry point
function __fcnf_no_subcommand
    set -l cmd (commandline -opc)
    test (count $cmd) -le 1
end

function __fcnf_feature_is
    set -l cmd (commandline -opc)
    test (count $cmd) -eq 2; and test "$cmd[2]" = $argv[1]
end

complete -c fcnf -f

# Top-level commands
complete -c fcnf -n __fcnf_no_subcommand -a on      -d 'Enable plugin'
complete -c fcnf -n __fcnf_no_subcommand -a off     -d 'Disable plugin (kill-switch)'
complete -c fcnf -n __fcnf_no_subcommand -a default -d 'Reset master switch to default'
complete -c fcnf -n __fcnf_no_subcommand -a status  -d 'Show current configuration'
complete -c fcnf -n __fcnf_no_subcommand -a preview -d 'Show all three layouts'
complete -c fcnf -n __fcnf_no_subcommand -a help    -d 'Show help'
complete -c fcnf -n __fcnf_no_subcommand -a layout  -d 'Output layout'
complete -c fcnf -n __fcnf_no_subcommand -a pacman  -d 'Pacman noconfirm flag'
complete -c fcnf -n __fcnf_no_subcommand -a batch   -d 'Batch mode for pipelines'
complete -c fcnf -n __fcnf_no_subcommand -a sudo    -d 'Shadow sudo wrapper'

# Per-feature values
complete -c fcnf -n '__fcnf_feature_is layout' -xa 'compact classic minimal default'
complete -c fcnf -n '__fcnf_feature_is pacman' -xa 'auto manual default'
complete -c fcnf -n '__fcnf_feature_is batch'  -xa 'on off default'
complete -c fcnf -n '__fcnf_feature_is sudo'   -xa 'on off default'
