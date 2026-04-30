function __fcnf_sudo_inner_cmd --argument-names seg
    # Recebe um segmento de pipeline cujo primeiro token é "sudo" e devolve
    # o comando real (primeiro arg não-flag), ou nada se não houver.
    # Compartilhado entre __fcnf_preexec (batch) e a função sudo wrapper.
    # Definido aqui no conf.d (eager-load) para não depender do autoload em
    # $fish_function_path — alguns setups só sincronizam conf.d/.
    set -l tokens (string split ' ' -- (string replace -ar ' +' ' ' -- (string trim -- $seg)))
    set -l skip_next 0
    # Pula tokens[1] = "sudo" (o chamador já validou).
    for i in (seq 2 (count $tokens))
        set -l arg $tokens[$i]
        test -z "$arg"; and continue
        if test $skip_next -eq 1
            set skip_next 0
            continue
        end
        if string match -q -- '-*' $arg
            # Flags curtas que consomem o próximo arg: -C -D -g -p -r -t -T -u
            string match -qr '^-[CDgprtTu]$' -- $arg; and set skip_next 1
            continue
        end
        echo $arg
        return
    end
end

function __fcnf_preexec --on-event fish_preexec
    # Reset to empty global so set -a appends globally for this run.
    set -g __fcnf_handled

    # Master kill-switch: plugin inteiro fora do caminho.
    if set -q fcnf_enabled; and test "$fcnf_enabled" = false
        return
    end

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
    set -l sudo_disabled_present 0

    for seg in $segments
        set -l seg_trim (string trim -- $seg)
        set -l tok (string split -m 1 ' ' -- $seg_trim)[1]
        test -z "$tok"; and continue

        # sudo é prefixo transparente: descer para o comando real para que
        # `sudo cmd_ausente; outro_ausente` dispare batch também.
        if test "$tok" = sudo
            # Wrapper desligado: kill-switch total. Marca a linha como
            # "off-limits" — qualquer ausência em outros segmentos também
            # será suprimida no fish_command_not_found, evitando UX híbrida
            # onde metade da linha é tratada e a outra metade falha nativa.
            if set -q fcnf_sudo_wrapper; and test "$fcnf_sudo_wrapper" = false
                set sudo_disabled_present 1
                continue
            end
            set tok (__fcnf_sudo_inner_cmd $seg_trim)
            test -z "$tok"; and continue
        end

        string match -qr '^[A-Za-z_][A-Za-z0-9_+.-]*$' -- $tok; or continue
        contains -- $tok $keywords; and continue
        contains -- $tok $seen; and continue
        set -a seen $tok
        type -q $tok; and continue
        set -a local_miss $tok
    end

    # Linha contém sudo com wrapper desligado → suprime tudo.
    # Marca os tokens ausentes como já-tratados para que fish_command_not_found
    # também se cale; o sudo nativo cuidará da própria mensagem.
    if test $sudo_disabled_present -eq 1
        test (count $local_miss) -gt 0; and set __fcnf_handled $local_miss
        return
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

    # Warning block — shown before the package list.
    if test $warn_path -eq 1
        echo (set_color --bold yellow)"::"(set_color normal)" "(set_color --bold yellow)"⚠"(set_color normal)" "(__fcnf_i18n batch_warn_cmds)
        for cmd in $no_pkg_cmds
            echo "     "(set_color --bold red)$cmd(set_color normal)
        end
        echo ""
    end

    # Header da lista — mesma estrutura visual nos dois caminhos, só muda a mensagem.
    set -l header_msg (test $warn_path -eq 1; and __fcnf_i18n batch_available $n; or __fcnf_i18n batch_summary $n)
    echo (set_color --bold blue)"::"(set_color normal)" "(set_color --bold)$header_msg(set_color normal)
    echo ""

    set -l w_cmd 0
    set -l w_pkg 0
    for i in (seq $n)
        set -l lc (string length -- $miss_cmds[$i])
        set -l lp (string length -- "$miss_repos[$i]/$miss_pkgs[$i]")
        test $lc -gt $w_cmd; and set w_cmd $lc
        test $lp -gt $w_pkg; and set w_pkg $lp
    end

    # Uma única chamada ao expac para todos os pacotes — evita N forks no loop de render.
    # Indexamos por nome porque expac pula pacotes não resolvidos, o que quebraria ordem posicional.
    set -l meta_lines (expac -S '%n\t%v\t%m\t%d' $miss_pkgs 2>/dev/null)
    for i in (seq $n)
        set -l ver ""
        set -l size_bytes ""
        set -l desc ""
        for ml in $meta_lines
            set -l f (string split \t -- $ml)
            if test "$f[1]" = "$miss_pkgs[$i]"
                set ver $f[2]
                set size_bytes $f[3]
                set desc $f[4]
                break
            end
        end
        __fcnf_print_batch_item $i $miss_cmds[$i] $miss_repos[$i] $miss_pkgs[$i] $w_cmd $w_pkg $ver $size_bytes $desc
    end
    echo ""

    if test $warn_path -eq 1
        echo (set_color --bold yellow)"::"(set_color normal)" "(__fcnf_i18n batch_warn_fail)
        echo ""
    end

    set -l prompt_msg (test $warn_path -eq 1; and __fcnf_i18n batch_prompt_warn; or __fcnf_i18n batch_prompt)
    set -l choice
    read -P (set_color --bold blue)"::"(set_color normal)" "(set_color --bold)$prompt_msg(set_color normal) choice
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

function __fcnf_setup_sudo_wrapper
    # Disjuntor: monta ou destrói a função shadow `sudo` em memória.
    # Master `fcnf_enabled=false` vence sobre `fcnf_sudo_wrapper`.
    # Como o arquivo no autoload se chama __fcnf_sudo.fish, o nome `sudo`
    # nunca é reclamado pelo plugin no nível de arquivo — só existe se nós
    # criarmos aqui. Erase é definitivo dentro da sessão.
    if set -q fcnf_enabled; and test "$fcnf_enabled" = false
        functions --erase sudo 2>/dev/null
        return
    end
    if not set -q fcnf_sudo_wrapper; or test "$fcnf_sudo_wrapper" = true
        function sudo --wraps sudo
            __fcnf_sudo $argv
        end
    else
        functions --erase sudo 2>/dev/null
    end
end

__fcnf_setup_sudo_wrapper

function __fcnf_on_sudo_wrapper_change --on-variable fcnf_sudo_wrapper
    __fcnf_setup_sudo_wrapper
    if not set -q fcnf_sudo_wrapper; or test "$fcnf_sudo_wrapper" = true
        echo (set_color --bold green)"✓"(set_color normal)" "(__fcnf_i18n sudo_wrapper_on)
    else if test "$fcnf_sudo_wrapper" = false
        echo (set_color --bold green)"✓"(set_color normal)" "(__fcnf_i18n sudo_wrapper_off)
    else
        echo (set_color --bold yellow)"⚠"(set_color normal)" "(__fcnf_i18n sudo_wrapper_invalid)
    end
end

function __fcnf_on_enabled_change --on-variable fcnf_enabled
    # Master kill-switch reagiu — refaz o estado da função sudo na hora.
    __fcnf_setup_sudo_wrapper
    if set -q fcnf_enabled; and test "$fcnf_enabled" = false
        echo (set_color --bold yellow)"⚠"(set_color normal)" "(__fcnf_i18n plugin_disabled)
    else if not set -q fcnf_enabled; or test "$fcnf_enabled" = true
        echo (set_color --bold green)"✓"(set_color normal)" "(__fcnf_i18n plugin_enabled)
    else
        echo (set_color --bold yellow)"⚠"(set_color normal)" "(__fcnf_i18n plugin_invalid)
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
