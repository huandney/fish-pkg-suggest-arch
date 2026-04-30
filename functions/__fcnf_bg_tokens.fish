function __fcnf_bg_tokens --argument-names cmdline
    # Identifica tokens de comandos em jobs background (terminados por '&' singular).
    # Esses precisam ser silenciados no fish_command_not_found, senão entram em
    # disputa com o job control: read recebe SIGTTIN, prompt morre em
    # "Operação cancelada", output paralelo se sobrepõe.
    #
    # Estratégia parse-time (mais confiável que checar PGRP em runtime, que
    # falha por race com a transição fg→bg):
    #   1. Protege '&&' (não é separador de job).
    #   2. Split em ';' e '&' singular preservando o terminador.
    #   3. Job que termina em '&' é background.
    #   4. Dentro do job bg, extrai cada sub-comando via split em |, &&, ||.
    set -l esc (printf '\001')
    set -l mark (printf '\037')
    set -l submark (printf '\036')
    set -l protected (string replace -ar '&&' $esc -- $cmdline)

    set -l marked (string replace -ar ';' ";$mark" -- $protected)
    set marked (string replace -ar '&' "&$mark" -- $marked)

    for job in (string split $mark -- $marked)
        set job (string trim -- $job)
        test -z "$job"; and continue
        string match -q '*&' -- $job; or continue
        set job (string sub -e -1 -- $job)
        set job (string replace -ar $esc '&&' -- $job)

        set -l subs (string split $submark -- (string replace -ar '\|\||&&|\|' $submark -- $job))
        for sub in $subs
            set sub (string trim -- $sub)
            test -z "$sub"; and continue
            set -l tok (string split -m 1 ' ' -- $sub)[1]
            test -z "$tok"; and continue
            if test "$tok" = sudo
                set tok (__fcnf_sudo_inner_cmd $sub)
                test -z "$tok"; and continue
            end
            echo $tok
        end
    end
end
