function sudo
    set -l cmd ""
    set -l skip_next 0

    for arg in $argv
        if test $skip_next -eq 1
            set skip_next 0
            continue
        end
        if string match -q -- '-*' $arg
            # These short flags consume the next argument
            string match -qr '^-[CDgprtTu]$' -- $arg; and set skip_next 1
            continue
        end
        set cmd $arg
        break
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
