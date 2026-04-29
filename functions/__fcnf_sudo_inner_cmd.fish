function __fcnf_sudo_inner_cmd --argument-names seg
    # Recebe um segmento de pipeline cujo primeiro token é "sudo" e devolve
    # o comando real (primeiro arg não-flag), ou nada se não houver.
    # Compartilhado entre preexec (batch) e a função sudo wrapper.
    set -l tokens (string split ' ' -- (string replace -ar ' +' ' ' -- (string trim -- $seg)))
    set -l skip_next 0
    # Pula tokens[1] = "sudo" (o chamador já validou).
    for i in (seq 2 (count $tokens))
        set -l arg $tokens[$i]
        test -z "$arg"; and continue
        if test $skip_next -eq 1
            set skip_next 0
            continue
        end
        if string match -q -- '-*' $arg
            # Flags curtas que consomem o próximo arg: -C -D -g -p -r -t -T -u
            string match -qr '^-[CDgprtTu]$' -- $arg; and set skip_next 1
            continue
        end
        echo $arg
        return
    end
end
