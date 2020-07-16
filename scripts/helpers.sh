#!/usr/bin/env bash

# pl33t helper functions

# get tmux session option value, prefer non-global one.
# WA for 'tmux show -A' not working as expected during startup.
GetTmuxOption() {
    local option_value="$(tmux show -qv $1)"
    if [[ -n ${option_value} ]]; then
        echo "${option_value}" # return non-empty session option
    else
        echo "$(tmux show -gqv $1)" # return global option as is
    fi
}

# separator format parser
SepFormatParser() {
    local format sep_formats="$(GetTmuxOption $1)"
    local dir_format_cntr

    for format in ${sep_formats//,/ }; do
        if [[ ${format} =~ ^(left|right)?(-(left|right)?)?$ ]]; then
            case ${format} in
                left* )
                    lsep_ndx[${dir_format_cntr}]=0
                    lsep_ndx[${dir_format_cntr} + 1]=2
                ;;&
                right* )
                    lsep_ndx[${dir_format_cntr}]=1
                    lsep_ndx[${dir_format_cntr} + 1]=3
                ;;&
                *left )
                    rsep_ndx[${dir_format_cntr}]=1
                    rsep_ndx[${dir_format_cntr} + 1]=2
                ;;&
                *right )
                    rsep_ndx[${dir_format_cntr}]=0
                    rsep_ndx[${dir_format_cntr} + 1]=3
                ;;&
                * )
                    (( dir_format_cntr+=2 ))
                ;;
            esac
        else
            case ${format} in
                clear ) # clear-style separators. default is opaque
                    clear='yes'
                ;;
                * )
                    sep_shape="${format}"
                ;;
            esac
        fi
    done
}

# tmux style string parser (with custom attrs)
StyleParser() {
    local style styles="$(GetTmuxOption $1)"
    for style in ${styles//,/ }; do
        case ${style} in
            [bf]g=* ) # fg,bg colors
                eval ${style}
            ;;
            tmp ) # temporal. only show if not empty
                tmp='yes'
            ;;
            * ) # the rest
                attr+="#,${style}"
            ;;
        esac
    done
    attr=${attr#\#,}
}
