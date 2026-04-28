function __fcnf_on_layout_change --on-variable fcnf_layout
    if not set -q fcnf_layout
        return
    end
    switch $fcnf_layout
        case compact classic minimal
            echo (set_color --bold green)"✓"(set_color normal)" Layout do fish-pkg-suggest-arch: "(set_color --bold)"$fcnf_layout"(set_color normal)"."
        case '*'
            echo (set_color --bold yellow)"⚠"(set_color normal)" Layout '"(set_color --bold)"$fcnf_layout"(set_color normal)"' inválido. Use: compact, classic ou minimal."
    end
end
