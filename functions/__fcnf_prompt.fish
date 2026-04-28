function __fcnf_prompt --argument-names layout pkg
    switch $layout
        case minimal
            echo (set_color --bold blue)"::"(set_color normal)" "(set_color --bold)"Deseja instalar? [S/n]: "(set_color normal)
        case '*'
            echo (set_color --bold blue)"::"(set_color normal)" "(set_color --bold)"Deseja instalar $pkg agora? [S/n] "(set_color normal)
    end
end
