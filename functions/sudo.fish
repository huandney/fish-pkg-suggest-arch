function sudo
    set -l cmd ""
    set -l skip_next 0

    for arg in $argv
        if test $skip_next -eq 1
            set skip_next 0
            continue
        end
        if string match -q -- '-*' $arg
            # These short flags consume the next argument
            string match -qr '^-[CDgprtTu]$' -- $arg; and set skip_next 1
            continue
        end
        set cmd $arg
        break
    end

    if test -n "$cmd"; and not type -q "$cmd"
        command -q pkgfile; and test -f /var/cache/pkgfile/.db_version; or begin
            command sudo $argv
            return
        end

        set -l matches (pkgfile -b "$cmd" 2>/dev/null)
        if test (count $matches) -gt 0
            set -l parts (string split "/" $matches[1])
            set -l repo $parts[1]
            set -l pkg $parts[2]
            set -l layout compact
            test -n "$fcnf_layout"; and set layout $fcnf_layout

            __fcnf_print $layout $cmd $repo $pkg $matches

            test -t 0; or begin
                command sudo $argv
                return
            end

            set -l confirm
            read -n 1 -P (__fcnf_prompt $layout $pkg) confirm
            echo ""

            switch (string lower -- $confirm)
                case '' i
                    __fcnf_install $pkg
                case e r
                    __fcnf_install $pkg
                    and command sudo $argv
                case '*'
                    echo (__fcnf_i18n op_cancelled)
            end
            return
        end
    end

    command sudo $argv
end
