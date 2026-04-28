function __fcnf_i18n --argument-names key sub1
    set -l lang en
    string match -q 'pt*' -- "$LANG$LC_MESSAGES"; and set lang pt

    switch "$lang:$key"
        # fish_command_not_found
        case 'pt:cmd_not_found';      echo "Comando não encontrado"
        case 'en:cmd_not_found';      echo "Command not found"
        case 'pt:pkgfile_hint';       echo "Dica: instale com 'sudo pacman -S pkgfile' e rode 'sudo pkgfile -u'"
        case 'en:pkgfile_hint';       echo "Tip: install with 'sudo pacman -S pkgfile' and run 'sudo pkgfile -u'"
        case 'pt:cache_not_init';     echo "Cache do pkgfile não inicializado."
        case 'en:cache_not_init';     echo "pkgfile cache not initialized."
        case 'pt:cache_init_cmd';     echo "Inicialize com:"
        case 'en:cache_init_cmd';     echo "Initialize with:"
        case 'pt:cache_keep_updated'; echo "Manter atualizado:"
        case 'en:cache_keep_updated'; echo "Keep updated:"
        case 'pt:install_success';    echo "Instalação concluída!"
        case 'en:install_success';    echo "Installation complete!"
        case 'pt:install_failed';     echo "Falha na instalação."
        case 'en:install_failed';     echo "Installation failed."
        case 'pt:op_cancelled';       echo "Operação cancelada."
        case 'en:op_cancelled';       echo "Operation cancelled."

        # headings (__fcnf_print)
        case 'pt:hdr_cmd';       echo "O comando"
        case 'en:hdr_cmd';       echo "Command"
        case 'pt:hdr_pkg';       echo "O pacote para"
        case 'en:hdr_pkg';       echo "Package for"
        case 'pt:not_installed'; echo "não está instalado."
        case 'en:not_installed'; echo "is not installed."
        case 'pt:not_found';     echo "não foi encontrado."
        case 'en:not_found';     echo "was not found."
        case 'pt:belongs_to';    echo "Pertence a"
        case 'en:belongs_to';    echo "Belongs to"
        case 'pt:also_in';       echo "também em:"
        case 'en:also_in';       echo "also in:"

        # classic layout labels
        case 'pt:lbl_repo';      echo "Repositório"
        case 'en:lbl_repo';      echo "Repository"
        case 'pt:lbl_version';   echo "Versão"
        case 'en:lbl_version';   echo "Version"
        case 'pt:lbl_desc';      echo "Descrição"
        case 'en:lbl_desc';      echo "Description"
        case 'pt:lbl_size';      echo "Tamanho"
        case 'en:lbl_size';      echo "Size"
        case 'pt:lbl_build';     echo "Compilação"
        case 'en:lbl_build';     echo "Build date"
        case 'pt:lbl_packager';  echo "Empacotador"
        case 'en:lbl_packager';  echo "Packager"
        case 'pt:lbl_site';      echo "Site Oficial"
        case 'en:lbl_site';      echo "Official Site"
        case 'pt:lbl_installed'; echo "instalado"
        case 'en:lbl_installed'; echo "installed"
        case '*:lbl_download';   echo "download"

        # compact layout labels
        case 'pt:lbl_pkg_compact';   echo "Pacote:"
        case 'en:lbl_pkg_compact';   echo "Package:"
        case '*:lbl_build_compact';  echo "Build:"
        case '*:lbl_site_compact';   echo "Site:"

        # prompts (__fcnf_prompt)
        case 'pt:prompt_minimal'; echo "Deseja instalar? [S/n]: "
        case 'en:prompt_minimal'; echo "Install? [Y/n]: "
        case 'pt:prompt_install'; echo "Deseja instalar $sub1 agora? [S/n] "
        case 'en:prompt_install'; echo "Install $sub1 now? [Y/n] "

        # conf.d
        case 'pt:layout_changed'; echo "Layout do fish-pkg-suggest-arch:"
        case 'en:layout_changed'; echo "fish-pkg-suggest-arch layout:"
        case 'pt:layout_invalid'; echo "inválido. Use: compact, classic ou minimal."
        case 'en:layout_invalid'; echo "invalid. Use: compact, classic or minimal."

        # fcnf-preview
        case 'pt:expac_missing';  echo "expac não está instalado."
        case 'en:expac_missing';  echo "expac is not installed."
        case 'pt:preview_choose'; echo "Para escolher:"
        case 'en:preview_choose'; echo "To choose:"
    end
end
