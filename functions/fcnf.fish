function fcnf --description 'fish-pkg-suggest-arch control'
    set -l valid_vars enabled layout pacman_noconfirm batch_mode sudo_wrapper

    set -l sub $argv[1]
    set -l rest $argv[2..-1]

    switch "$sub"
        case set
            if test (count $rest) -lt 2
                echo "fcnf set: missing arguments. Usage: fcnf set <var> <value>" >&2
                return 1
            end
            set -l var (string replace -r '^fcnf_' '' -- $rest[1])
            if not contains -- $var $valid_vars
                echo "fcnf: unknown variable '$var'. Valid: $valid_vars" >&2
                return 1
            end
            # Sentinel ANTES da var: handler vê origem na hora do disparo.
            set -U __fcnf_origin_pid $fish_pid
            set -U fcnf_$var $rest[2..-1]

        case unset
            if test (count $rest) -lt 1
                echo "fcnf unset: missing variable name" >&2
                return 1
            end
            set -l var (string replace -r '^fcnf_' '' -- $rest[1])
            if not contains -- $var $valid_vars
                echo "fcnf: unknown variable '$var'" >&2
                return 1
            end
            set -U __fcnf_origin_pid $fish_pid
            set -e -U fcnf_$var

        case preview
            __fcnf_preview_layouts

        case '' help -h --help
            __fcnf_help

        case '*'
            echo "fcnf: unknown subcommand '$sub'" >&2
            __fcnf_help >&2
            return 1
    end
end

function __fcnf_help
    echo "Usage: fcnf <subcommand> [args]"
    echo ""
    echo "Subcommands:"
    echo "  set <var> <value>   Set a fcnf_* configuration variable (universal)"
    echo "  unset <var>         Remove a fcnf_* variable (revert to default)"
    echo "  preview             Show all three layouts side by side"
    echo "  help                Show this message"
    echo ""
    echo "Variables: enabled, layout, pacman_noconfirm, batch_mode, sudo_wrapper"
end

function __fcnf_preview_layouts
    if not command -q expac
        echo (__fcnf_i18n expac_missing)
        return 1
    end

    set -l demo_cmd pacman
    set -l demo_repo core
    set -l demo_pkg pacman

    for layout in compact classic minimal
        echo (set_color --bold)"─── Layout: $layout ───"(set_color normal)
        echo ""
        __fcnf_print $layout $demo_cmd $demo_repo $demo_pkg "$demo_repo/$demo_pkg"
        echo (__fcnf_prompt $layout $demo_pkg)
        echo ""
        echo ""
    end

    echo (__fcnf_i18n preview_choose)" "(set_color --bold)"fcnf set layout <compact|classic|minimal>"(set_color normal)
end
