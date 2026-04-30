#!/usr/bin/env fish
# Symlinks the project's fish files into ~/.config/fish for live development.
# Edits no repositório aparecem após `exec fish` (ou `functions --erase <nome>`)
# sem precisar passar por makepkg/pacman.
#
# Uso:
#   ./dev-link.fish            # cria/atualiza os symlinks
#   ./dev-link.fish --unlink   # remove os symlinks que apontam para este repo

set -l project_dir (realpath (dirname (status filename)))
set -l fish_config $__fish_config_dir
set -l action link
test "$argv[1]" = --unlink; and set action unlink

# Aviso útil: a versão do pacote sobrepõe quando ambos estão presentes
# em alguns layouts; em geral o user-config tem precedência sobre vendor_*,
# mas vale alertar para evitar confusão.
if pacman -Q fish-pkg-suggest-arch-git &>/dev/null
    echo (set_color yellow)"⚠"(set_color normal)" Pacote fish-pkg-suggest-arch-git instalado via pacman."
    echo "  Considere desinstalar para evitar conflito durante o dev:"
    echo "    sudo pacman -R fish-pkg-suggest-arch-git"
    echo ""
end

function __link --argument-names src dst action
    if test "$action" = unlink
        if test -L $dst; and test (realpath $dst) = (realpath $src)
            rm $dst
            echo "  - $dst"
        end
        return
    end

    mkdir -p (dirname $dst)
    # Substitui apenas se já for symlink (não sobrescreve arquivo regular do user).
    if test -e $dst; and not test -L $dst
        echo (set_color red)"  ✗ $dst existe e não é symlink — pulando."(set_color normal)
        return
    end
    ln -sfn $src $dst
    echo "  → $dst"
end

set -l action_label "Linkando"
test "$action" = unlink; and set action_label "Removendo links de"
echo (set_color --bold)"$action_label "(string replace $HOME '~' $project_dir)" → "(string replace $HOME '~' $fish_config)(set_color normal)

__link $project_dir/conf.d/fcnf.fish $fish_config/conf.d/fcnf.fish $action

for f in $project_dir/functions/*.fish
    __link $f $fish_config/functions/(basename $f) $action
end

if test -d $project_dir/completions
    for f in $project_dir/completions/*.fish
        __link $f $fish_config/completions/(basename $f) $action
    end
end

echo ""
if test "$action" = link
    echo (set_color green)"✓"(set_color normal)" Pronto. Rode "(set_color --bold)"exec fish"(set_color normal)" para recarregar."
else
    echo (set_color green)"✓"(set_color normal)" Symlinks removidos. Rode "(set_color --bold)"exec fish"(set_color normal)"."
end
