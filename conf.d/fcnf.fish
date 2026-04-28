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
