function __fcnf_sudo
    # Background-job guard: invocações via `&` (ex: `sudo cmd &`) caem em um
    # process group diferente do TTY owner. Mostrar prompt ali quebra a UX
    # (output paralelo, SIGTTIN no `read`). Vaza para o sudo nativo, que
    # imprime sua mensagem de erro e segue. Mesma lógica do fish_command_not_found.
    set -l pgrp (command ps -o pgrp= -p %self 2>/dev/null | string trim)
    set -l tpgid (command ps -o tpgid= -p %self 2>/dev/null | string trim)
    if test -n "$pgrp"; and test "$pgrp" != "$tpgid"
        command sudo $argv
        return
    end

    # Cinto-e-suspensórios: se algo herdar essa função em contexto não-interativo
    # (subshell, command substitution, script rodando dentro de shell interativo),
    # vaza direto para o sudo do sistema.
    if not status is-interactive
        command sudo $argv
        return
    end

    # Mesmo parser que o preexec usa, para que ambos enxerguem o mesmo
    # "comando interno" diante de flags exóticas do sudo.
    set -l cmd (__fcnf_sudo_inner_cmd "sudo $argv")

    # preexec já tratou esse comando neste fish_preexec (instalou ou cancelou)
    # → suprime totalmente. Sem isso, fish executaria 'sudo cmd_ausente' e o
    # sudo do sistema pediria senha antes de falhar com 'command not found'.
    if set -q __fcnf_handled; and contains -- "$cmd" $__fcnf_handled
        return 0
    end

    # Sem comando detectado, ou comando já existe → sudo direto.
    if test -z "$cmd"; or type -q "$cmd"
        command sudo $argv
        return
    end

    # Sem cache do pkgfile não temos como sugerir → sudo direto.
    if not command -q pkgfile; or not test -f /var/cache/pkgfile/.db_version
        command sudo $argv
        return
    end

    set -l matches (pkgfile -b "$cmd" 2>/dev/null)
    if test (count $matches) -eq 0
        command sudo $argv
        return
    end

    set -l parts (string split "/" $matches[1])
    set -l repo $parts[1]
    set -l pkg $parts[2]
    set -l layout compact
    test -n "$fcnf_layout"; and set layout $fcnf_layout

    __fcnf_print $layout $cmd $repo $pkg $matches

    # Sem TTY (pipe/script) não dá para perguntar → sudo direto.
    if not test -t 0
        command sudo $argv
        return
    end

    set -l confirm
    read -n 1 -P (__fcnf_prompt $layout $pkg) confirm
    or begin
        echo ""
        echo (__fcnf_i18n op_cancelled)
        return
    end
    echo ""

    switch (string lower -- $confirm)
        case '' i
            __fcnf_install $pkg
        case e r
            __fcnf_install $pkg
            and command sudo $argv
        case '*'
            echo (__fcnf_i18n op_cancelled)
    end
end
