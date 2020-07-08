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

# separator format picker
SepFormatPicker() {
    local -a input_list=("${!1}")
    local sep_dir=$2
    sep_format_picker_list=('' '')

    case ${sep_dir} in
        left* )
            sep_format_picker_list[0]="${input_list[0]}${input_list[2]}"
        ;;&
        right* )
            sep_format_picker_list[0]="${input_list[1]}${input_list[3]}"
        ;;&
        *left )
            sep_format_picker_list[1]="${input_list[1]}${input_list[2]}"
        ;;&
        *right )
            sep_format_picker_list[1]="${input_list[0]}${input_list[3]}"
        ;;
    esac
}

# tmux style string parser (with custom attrs)
StyleParser() {
    local style="$(GetTmuxOption $1)"
    local i
    fg= bg= attr= tmp= clear=
    for i in $(echo ${style//,/ }); do
        case $i in
            [bf]g=* ) # fg,bg colors
                eval $i
            ;;
            tmp ) # temporal. only show if not empty
                tmp='yes'
            ;;
            clear ) # clear-style separators. default is opaque
                clear='yes'
            ;;
            * ) # the rest
                attr+="#,$i"
            ;;
        esac
    done
    attr=${attr#\#,}
}
