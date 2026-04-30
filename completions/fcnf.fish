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

function __fcnf_using_subcommand
    set -l cmd (commandline -opc)
    test (count $cmd) -ge 2; and test "$cmd[2]" = $argv[1]
end

function __fcnf_set_needs_var
    set -l cmd (commandline -opc)
    test (count $cmd) -eq 2; and test "$cmd[2]" = set
end

function __fcnf_set_needs_value
    set -l cmd (commandline -opc)
    test (count $cmd) -eq 3; and test "$cmd[2]" = set
end

function __fcnf_unset_needs_var
    set -l cmd (commandline -opc)
    test (count $cmd) -eq 2; and test "$cmd[2]" = unset
end

complete -c fcnf -f

complete -c fcnf -n __fcnf_no_subcommand -a set    -d 'Set a fcnf_* variable'
complete -c fcnf -n __fcnf_no_subcommand -a unset  -d 'Remove a fcnf_* variable'
complete -c fcnf -n __fcnf_no_subcommand -a preview -d 'Show all three layouts'
complete -c fcnf -n __fcnf_no_subcommand -a help   -d 'Show help'

set -l fcnf_vars 'enabled\t"Master kill-switch" layout\t"Output layout" pacman_noconfirm\t"Skip pacman prompt" batch_mode\t"Batch mode for pipelines" sudo_wrapper\t"Shadow sudo wrapper"'

complete -c fcnf -n __fcnf_set_needs_var   -xa "$fcnf_vars"
complete -c fcnf -n __fcnf_unset_needs_var -xa "$fcnf_vars"

# Value completion for `fcnf set <var> <TAB>`
function __fcnf_set_value_for
    set -l cmd (commandline -opc)
    test (count $cmd) -ne 3; and return 1
    test "$cmd[2]" != set; and return 1
    test "$cmd[3]" = $argv[1]
end

complete -c fcnf -n '__fcnf_set_value_for layout'           -xa 'compact classic minimal'
complete -c fcnf -n '__fcnf_set_value_for enabled'          -xa 'true false'
complete -c fcnf -n '__fcnf_set_value_for pacman_noconfirm' -xa 'true false'
complete -c fcnf -n '__fcnf_set_value_for batch_mode'       -xa 'true false'
complete -c fcnf -n '__fcnf_set_value_for sudo_wrapper'     -xa 'true false'
