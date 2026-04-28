function fish_command_not_found
    if not command -q pkgfile
        echo "Comando não encontrado: $argv[1]"
        echo "Dica: instale com 'sudo pacman -S pkgfile' e rode 'sudo pkgfile -u'"
        return
    end

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

    set -l layout compact
    test -n "$fcnf_layout"; and set layout $fcnf_layout

    __fcnf_print $layout $argv[1] $repo $pkg $matches

    set -l confirm
    read -n 1 confirm
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
