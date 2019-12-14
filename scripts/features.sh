#!/usr/bin/env bash

# timer based function caller for tmux status line
# designed to avoid binding invocations to status-interval updates

# orchestrator
main() {
    fn_name=$1      # shell function name to run
    fn_freq=$2      # shell function invocation frequency
    # get the function arguments
    shift 2
    fn_opts="$@"    # function options if any

    # tmux var name to store shell function result data
    tmux_var="@pl33t-features-${fn_name}-output"
    # get frequency of this script invocations
    self_freq=$(tmux display -p '#{status-interval}')

    # absolute time
    abs_time=$(date +%s)
    # run shell function if it's time or the first time
    if [[ $(( ${abs_time} % ${fn_freq} )) -lt ${self_freq} ]] ||
       [[ -z $(tmux display -p "#{${tmux_var}}") ]]; then
        ${fn_name} "${fn_opts}"
    fi
    echo "#{${tmux_var}}"
}

# cli weather
wttr() {
    # CLI weather.
    # help: curl wttr.in/:help
    # homepage: https://github.com/chubin/wttr.in
    local opts=${1:-'?format=3'}        # defaults to oneline format 3 output
    local result="$(curl --compressed --max-time 10 wttr.in/${opts})"
    tmux set ${tmux_var} "${result}"
}

# get public ip
publicip() {
    local methods=(dig curl wget)
    local method result

    for method in ${methods[@]}; do
        case ${method} in
            'dig' )
                result=$(dig +time=1 +tries=1 +short myip.opendns.com @resolver1.opendns.com 2> /dev/null)
                [[ ${result} =~ ^\; ]] && unset result
            ;;
            'curl' )
                result=$(curl --max-time 10 -w '\n' http://ident.me 2> /dev/null)
            ;;
            'wget' )
                result=$(wget -T 10 -qO- http://ident.me 2> /dev/null)
            ;;
        esac
        # break if result is found
        [[ -n ${result} ]] && break
    done

    tmux set ${tmux_var} "${result}"
}

main $@
