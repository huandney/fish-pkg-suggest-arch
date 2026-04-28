function fish_command_not_found
    if not command -q pkgfile
        echo (__fcnf_i18n cmd_not_found)": $argv[1]"
        echo (__fcnf_i18n pkgfile_hint)
        return
    end

    if not test -f /var/cache/pkgfile/.db_version
        echo (__fcnf_i18n cmd_not_found)": $argv[1]"
        echo ""
        echo "  "(set_color yellow)"⚠"(set_color normal)" "(__fcnf_i18n cache_not_init)
        echo "    "(__fcnf_i18n cache_init_cmd)" "(set_color --bold)"sudo pkgfile -u"(set_color normal)
        echo "    "(__fcnf_i18n cache_keep_updated)" "(set_color --bold)"sudo systemctl enable --now pkgfile-update.timer"(set_color normal)
        return
    end

    set -l matches (pkgfile -b $argv[1] 2>/dev/null)
    if test (count $matches) -eq 0
        echo (__fcnf_i18n cmd_not_found)": $argv[1]"
        return
    end

    set -l full_pkg $matches[1]
    set -l repo (string split "/" $full_pkg)[1]
    set -l pkg (string split "/" $full_pkg)[2]

    set -l layout compact
    test -n "$fcnf_layout"; and set layout $fcnf_layout

    __fcnf_print $layout $argv[1] $repo $pkg $matches

    set -l prompt (__fcnf_prompt $layout $pkg)
    set -l confirm
    read -n 1 -P "$prompt" confirm
    echo ""

    if string match -qri '^(s|y)?$' -- $confirm
        if sudo pacman -S $pkg
            echo ""
            echo "  "(set_color --bold green)"✓"(set_color normal)" "(__fcnf_i18n install_success)
            echo ""
        else
            echo ""
            echo "  "(set_color --bold red)"✗"(set_color normal)" "(__fcnf_i18n install_failed)
            echo ""
            return 1
        end
    else
        echo (__fcnf_i18n op_cancelled)
    end
end
