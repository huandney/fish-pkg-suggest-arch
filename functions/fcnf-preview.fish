function fcnf-preview --description 'Mostra os 3 layouts do fish-pkg-suggest-arch'
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

    echo (__fcnf_i18n preview_choose)" "(set_color --bold)"set -U fcnf_layout <compact|classic|minimal>"(set_color normal)
end
