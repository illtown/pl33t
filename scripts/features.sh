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
    local method ip ipv4 ipv6
    local public_ipv4_host='https://v4.ident.me'
    local public_ipv6_host='https://v6.ident.me'

    for method in ${methods[@]}; do
        case ${method} in
            'dig' )
                ipv4=$(dig +tries=1 +short -4 A myip.opendns.com @resolver1.opendns.com 2>/dev/null)
                ipv6=$(dig +tries=1 +short -6 AAAA myip.opendns.com @resolver1.opendns.com 2>/dev/null)
            ;;
            'curl' )
                ipv4=$(curl --max-time 5 -w '\n' ${public_ipv4_host} 2>/dev/null)
                ipv6=$(curl --max-time 5 -w '\n' ${public_ipv6_host} 2>/dev/null)
            ;;
            'wget' )
                ipv4=$(wget -T 5 -qO- ${public_ipv4_host} 2>/dev/null)
                ipv6=$(wget -T 5 -qO- ${public_ipv6_host} 2>/dev/null)
            ;;
        esac
        # break if ip is found
        [[ ${ipv4} =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && { ip=${ipv4}; break; }
        [[ ${ipv6} =~ ^[0-9a-f:]{3,39}$ ]] && { ip=${ipv6}; break; }
    done

    tmux set ${tmux_var} "${ip}"
}

main $@
