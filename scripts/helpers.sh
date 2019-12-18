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
    local -a in_sep_format_list=("${!1}")
    local sep_dir=$2
    sep_format_picker_list=('' '')

    case ${sep_dir} in
        left* )
            sep_format_picker_list[0]="${in_sep_format_list[0]}${in_sep_format_list[2]}"
        ;;&
        right* )
            sep_format_picker_list[0]="${in_sep_format_list[1]}${in_sep_format_list[3]}"
        ;;&
        *left )
            sep_format_picker_list[1]="${in_sep_format_list[1]}${in_sep_format_list[2]}"
        ;;&
        *right )
            sep_format_picker_list[1]="${in_sep_format_list[0]}${in_sep_format_list[3]}"
        ;;
    esac
}

# tmux style string parser
StyleParser() {
    local style="$(GetTmuxOption $1)"
    local i
    fg= bg= attr=
    for i in $(echo ${style} | sed -E 's/,+/ /g'); do
        case $i in
            [bf]g=* )
                eval $i ;;
            * )
                attr+="$i#," ;;
        esac
    done
}
