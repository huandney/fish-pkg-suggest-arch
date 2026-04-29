function __fcnf_preexec --on-event fish_preexec
    # Reset to empty global so set -a appends globally for this run.
    set -g __fcnf_handled

    command -q pkgfile; or return
    test -f /var/cache/pkgfile/.db_version; or return

    set -l cmdline $argv[1]
    test -z "$cmdline"; and return

    set -l sep (printf '\037')
    set -l segments (string split $sep -- (string replace -ar '[|&;]+' $sep -- $cmdline))

    set -l keywords if else for while function begin end switch case not and or command builtin exec time set status return break continue test true false read echo printf

    # Phase 1 — pure in-memory filtering. No I/O.
    set -l seen
    set -l local_miss

    for seg in $segments
        set -l tok (string split -m 1 ' ' -- (string trim -- $seg))[1]
        test -z "$tok"; and continue
        string match -qr '^[A-Za-z_][A-Za-z0-9_+.-]*$' -- $tok; or continue
        contains -- $tok $keywords; and continue
        contains -- $tok $seen; and continue
        set -a seen $tok
        type -q $tok; and continue
        set -a local_miss $tok
    end

    # Single (or no) missing → let fish_command_not_found handle it. No I/O here.
    test (count $local_miss) -lt 2; and return

    # Phase 2 — I/O. Resolve only the locally-missing tokens via pkgfile.
    set -l miss_cmds
    set -l miss_pkgs
    set -l miss_repos
    set -l no_pkg_cmds

    for tok in $local_miss
        set -l matches (pkgfile -b $tok 2>/dev/null)
        if test (count $matches) -eq 0
            set -a no_pkg_cmds $tok
            continue
        end
        set -l parts (string split "/" $matches[1])
        set -a miss_cmds $tok
        set -a miss_repos $parts[1]
        set -a miss_pkgs $parts[2]
    end

    set -l n (count $miss_cmds)
    set -l warn_path (test (count $no_pkg_cmds) -gt 0; and echo 1; or echo 0)

    # Need 2+ installable, or 1+ installable with a warning.
    if test $n -eq 0; or begin test $n -lt 2; and test $warn_path -eq 0; end
        return
    end

    echo ""

    # Warning block — shown before the package list.
    if test $warn_path -eq 1
        echo (set_color --bold yellow)"::"(set_color normal)" "(set_color --bold yellow)"⚠"(set_color normal)" "(__fcnf_i18n batch_warn_cmds)
        for cmd in $no_pkg_cmds
            echo "     "(set_color --bold red)$cmd(set_color normal)
        end
        echo ""
        echo (set_color --bold blue)"::"(set_color normal)" "(set_color --bold)(__fcnf_i18n batch_available $n)(set_color normal)
    else
        echo (set_color --bold blue)"::"(set_color normal)" "(set_color --bold)(__fcnf_i18n batch_summary $n)(set_color normal)
    end
    echo ""

    set -l w_cmd 0
    set -l w_pkg 0
    for i in (seq $n)
        set -l lc (string length -- $miss_cmds[$i])
        set -l lp (string length -- "$miss_repos[$i]/$miss_pkgs[$i]")
        test $lc -gt $w_cmd; and set w_cmd $lc
        test $lp -gt $w_pkg; and set w_pkg $lp
    end

    for i in (seq $n)
        __fcnf_print_batch_item $i $miss_cmds[$i] $miss_repos[$i] $miss_pkgs[$i] $w_cmd $w_pkg
    end
    echo ""

    if test $warn_path -eq 1
        echo (set_color --bold yellow)"::"(set_color normal)" "(__fcnf_i18n batch_warn_fail)
        echo ""
    end

    set -l choice
    if test $warn_path -eq 1
        read -P (set_color --bold blue)"::"(set_color normal)" "(set_color --bold)(__fcnf_i18n batch_prompt_warn)(set_color normal) choice
    else
        read -P (set_color --bold blue)"::"(set_color normal)" "(set_color --bold)(__fcnf_i18n batch_prompt)(set_color normal) choice
    end
    or begin
        echo ""
        echo (__fcnf_i18n op_cancelled)
        set __fcnf_handled $miss_cmds
        return
    end
    set choice (string trim -- $choice)

    # Cancel conditions: explicit 'c', or empty on warning path.
    if string match -qri '^c$' -- $choice; or begin test $warn_path -eq 1; and test -z "$choice"; end
        echo (__fcnf_i18n op_cancelled)
        set __fcnf_handled $miss_cmds
        return
    end

    set -l to_install

    # Empty on happy path or 't' on warning path = install all.
    if test -z "$choice"; or string match -qri '^[ta]$' -- $choice
        set to_install $miss_pkgs
    else
        # Parse "1 2 3", "1,2,3", "1-3", or any combination.
        set -l selected
        for tok in (string split ' ' -- (string replace -ar '[, ]+' ' ' -- $choice))
            test -z "$tok"; and continue
            if string match -qr '^[0-9]+-[0-9]+$' -- $tok
                set -l range (string split '-' -- $tok)
                for i in (seq $range[1] $range[2])
                    test $i -ge 1 -a $i -le $n; and set -a selected $i
                end
            else if string match -qr '^[0-9]+$' -- $tok
                test $tok -ge 1 -a $tok -le $n; and set -a selected $tok
            end
        end

        if test (count $selected) -eq 0
            echo (__fcnf_i18n op_cancelled)
            set __fcnf_handled $miss_cmds
            return
        end

        for i in (seq $n)
            if contains $i $selected
                set -a to_install $miss_pkgs[$i]
            else
                set -a __fcnf_handled $miss_cmds[$i]
            end
        end
    end

    test (count $to_install) -eq 0; and return

    __fcnf_install $to_install
    or set __fcnf_handled $miss_cmds
end

function __fcnf_on_noconfirm_change --on-variable fcnf_pacman_noconfirm
    if not set -q fcnf_pacman_noconfirm
        echo (set_color --bold green)"✓"(set_color normal)" "(__fcnf_i18n noconfirm_off)
        return
    end
    switch $fcnf_pacman_noconfirm
        case true
            echo (set_color --bold green)"✓"(set_color normal)" "(__fcnf_i18n noconfirm_on)
        case false
            echo (set_color --bold green)"✓"(set_color normal)" "(__fcnf_i18n noconfirm_off)
        case '*'
            echo (set_color --bold yellow)"⚠"(set_color normal)" "(__fcnf_i18n noconfirm_invalid)
    end
end

function __fcnf_on_layout_change --on-variable fcnf_layout
    if not set -q fcnf_layout
        return
    end
    switch $fcnf_layout
        case compact classic minimal
            echo (set_color --bold green)"✓"(set_color normal)" "(__fcnf_i18n layout_changed)" "(set_color --bold)"$fcnf_layout"(set_color normal)"."
        case '*'
            echo (set_color --bold yellow)"⚠"(set_color normal)" Layout '"(set_color --bold)"$fcnf_layout"(set_color normal)"' "(__fcnf_i18n layout_invalid)
    end
end
