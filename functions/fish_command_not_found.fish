function fish_command_not_found
    if not command -q pkgfile
        echo "Comando não encontrado: $argv[1]"
        echo "Dica: instale com 'sudo pacman -S pkgfile' e rode 'sudo pkgfile -u'"
        return
    end

    # Cache do pkgfile inicializado? .db_version é o marcador que o próprio pkgfile usa.
    if not test -f /var/cache/pkgfile/.db_version
        echo "Comando não encontrado: $argv[1]"
        echo ""
        echo "  "(set_color yellow)"⚠"(set_color normal)" Cache do pkgfile não inicializado."
        echo "    Inicialize com: "(set_color --bold)"sudo pkgfile -u"(set_color normal)
        echo "    Manter atualizado: "(set_color --bold)"sudo systemctl enable --now pkgfile-update.timer"(set_color normal)
        return
    end

    set -l matches (pkgfile -b $argv[1] 2>/dev/null)
    if test (count $matches) -eq 0
        echo "Comando não encontrado: $argv[1]"
        return
    end

    set -l full_pkg $matches[1]
    set -l repo (string split "/" $full_pkg)[1]
    set -l pkg (string split "/" $full_pkg)[2]

    # Metadados (uma chamada de expac, parse nativo)
    set -l info (expac -S --timefmt='%d/%m/%Y' '%u\t%m\t%v\t%b\t%p' $pkg 2>/dev/null)
    set -l fields (string split \t -- $info)
    set -l pkg_url $fields[1]
    set -l pkg_size_bytes $fields[2]
    set -l pkg_version $fields[3]
    set -l pkg_builddate $fields[4]
    set -l pkg_packager $fields[5]

    # Hyperlink do repositório para repos oficiais do Arch
    set -l ESC (printf '\033')
    set -l repo_url ""
    switch $repo
        case core extra multilib
            set repo_url "https://archlinux.org/packages/$repo/x86_64/$pkg/"
    end
    set -l repo_display "$repo/$pkg"
    if test -n "$repo_url"
        set repo_display "$ESC]8;;$repo_url$ESC\\$repo/$pkg$ESC]8;;$ESC\\"
    end

    # Tamanho formatado
    set -l pkg_size ""
    if test -n "$pkg_size_bytes"; and test "$pkg_size_bytes" -gt 0 2>/dev/null
        set pkg_size (numfmt --to=iec --suffix=B $pkg_size_bytes)
    end

    # Escolha de layout (classic | compact)
    set -l layout compact
    test -n "$fcnf_layout"; and set layout $fcnf_layout

    switch $layout
        case classic
            set -l w 15
            echo " O pacote para "(set_color --bold red)"$argv[1]"(set_color normal)" não está instalado."
            echo ""
            echo "  "(string pad -rw $w "Repositório")(set_color blue)"$repo_display"(set_color normal)
            if test (count $matches) -gt 1
                echo "  "(string pad -rw $w "")(set_color --dim)"(também em: "(string join ", " $matches[2..])")"(set_color normal)
            end
            test -n "$pkg_version"; and echo "  "(string pad -rw $w "Versão")(set_color magenta)"$pkg_version"(set_color normal)
            test -n "$pkg_size"; and echo "  "(string pad -rw $w "Tamanho")(set_color yellow)"$pkg_size"(set_color normal)
            test -n "$pkg_builddate"; and echo "  "(string pad -rw $w "Compilado em")"$pkg_builddate"
            test -n "$pkg_packager"; and echo "  "(string pad -rw $w "Empacotador")"$pkg_packager"
            test -n "$pkg_url"; and echo "  "(string pad -rw $w "Site Oficial")(set_color cyan)"$pkg_url"(set_color normal)
            echo ""

            set -l prompt (set_color --bold blue)"::"(set_color normal)" Deseja instalar '$pkg' agora? [S/n] "
            read -n 1 -P "$prompt" confirm

        case '*'
            # Compact (default)
            set -l w 8
            set -l pkg_line "$repo_display"
            test -n "$pkg_version"; and set pkg_line "$pkg_line "(set_color --dim)"(v$pkg_version)"(set_color normal)
            test -n "$pkg_size"; and set pkg_line "$pkg_line "(set_color yellow)"[$pkg_size]"(set_color normal)

            set -l build_line ""
            test -n "$pkg_builddate"; and set build_line "$pkg_builddate"
            if test -n "$pkg_packager"
                if test -n "$build_line"
                    set build_line "$build_line "(set_color --dim)"($pkg_packager)"(set_color normal)
                else
                    set build_line "$pkg_packager"
                end
            end

            echo "  "(set_color --bold red)"✗"(set_color normal)" '"(set_color --bold)"$argv[1]"(set_color normal)"' não está instalado."
            echo "  "(set_color --bold cyan)"↳"(set_color normal)" "(set_color --bold)(string pad -rw $w "Pacote:")(set_color normal)"$pkg_line"
            if test (count $matches) -gt 1
                echo "    "(set_color --dim)"também em: "(string join ", " $matches[2..])(set_color normal)
            end
            test -n "$build_line"; and echo "  "(set_color --bold cyan)"↳"(set_color normal)" "(set_color --bold)(string pad -rw $w "Build:")(set_color normal)"$build_line"
            test -n "$pkg_url"; and echo "  "(set_color --bold cyan)"↳"(set_color normal)" "(set_color --bold)(string pad -rw $w "Site:")(set_color normal)(set_color cyan)"$pkg_url"(set_color normal)

            set -l prompt " "(set_color --bold blue)"::"(set_color normal)" Deseja instalar '$pkg' agora? [S/n] "
            read -n 1 -P "$prompt" confirm
    end

    echo ""

    if string match -qri '^(s|y)?$' -- $confirm
        if sudo pacman -S $pkg
            echo ""
            echo "  "(set_color --bold green)"✓"(set_color normal)" Instalação concluída!"
            echo ""
        else
            echo ""
            echo "  "(set_color --bold red)"✗"(set_color normal)" Falha na instalação."
            echo ""
            return 1
        end
    else
        echo "Operação cancelada."
    end
end
