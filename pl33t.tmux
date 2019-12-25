#!/usr/bin/env bash

# Tmux pl33t theme

# main starting point
Main() {
    #SanityCheck
    CURRENT_DIR="$(dirname $0)"
    source "${CURRENT_DIR}/scripts/helpers.sh"
    source "${CURRENT_DIR}/scripts/variables.sh"
    ApplyTheme
    Features
}

# sanity check
SanityCheck() {
    # Tmux version check
    if ! [[ "$(tmux -V)" =~ ^tmux\ [3-9] ]]; then
        tmux display "$(basename $0): Tmux version 3+ needed"
        exit 1
    fi
}

# apply theme in stages
ApplyTheme() {
    # pane modifications
    PaneModding

    # status lines modifications
    pl33t_status_lines=$(GetTmuxOption @pl33t-status-lines)
    if [[ ${pl33t_status_lines} =~ ^[2-5]$ ]]; then
        for (( i=0; i<${pl33t_status_lines}; i++ )); do
            StatusLineModding $i
        done
    else
        StatusLineModding 0
    fi
}

# feature scripts
Features() {
    local features_list=(wttr publicip)
    local feature

    for feature in ${features_list[@]}; do
        if [[ $(GetTmuxOption @pl33t-features-${feature}-toggle) == 'on' ]]; then
            local interval=$(GetTmuxOption @pl33t-features-${feature}-interval)
            : ${interval:=60}
            local options=$(GetTmuxOption @pl33t-features-${feature}-options)
            tmux set -g @pl33t-features-${feature} "#(${CURRENT_DIR}/scripts/features.sh ${feature} ${interval} ${options})"
        else
            tmux set -gu @pl33t-features-${feature}
        fi
    done
}

# pane modifications
PaneModding() {
    # pane border format
    local pane_separator=$(GetTmuxOption @pl33t-pane-border-separator)
    local pane_active_separator=$(GetTmuxOption @pl33t-pane-active-border-separator)
    local pane_border_format=''

    # pane border format builder
    pane_border_format+='#{?pane_active,'
    # active pane border
    eval pane_border_format+="#{?pane_marked,#[reverse]\${pl33t_pl_${pane_active_separator}_left_opaque}#[noreverse],}" # marked
    pane_border_format+="#[#{E:@pl33t-pane-active-border-style}]" # WA for 'align' not being inherited
    eval pane_border_format+="\${pl33t_pl_${pane_active_separator}_left_opaque}" # left separator
    pane_border_format+="#[reverse]#{T:@pl33t-pane-active-border-content}#[noreverse]" # content
    eval pane_border_format+="\${pl33t_pl_${pane_active_separator}_right_opaque}" # right separator
    eval pane_border_format+="#{?pane_marked,#[default#,align=right#,reverse]\${pl33t_pl_${pane_active_separator}_right_opaque}#[noreverse],}" # marked
    pane_border_format+=","
    # normal pane border
    eval pane_border_format+="#{?pane_marked,#[reverse]\${pl33t_pl_${pane_separator}_left_opaque}#[noreverse],}" # marked
    pane_border_format+="#[#{E:@pl33t-pane-border-style}]" # WA for 'align' not being inherited
    eval pane_border_format+="\${pl33t_pl_${pane_separator}_left_clear}" # left separator
    pane_border_format+="#{T:@pl33t-pane-border-content}" # content
    eval pane_border_format+="\${pl33t_pl_${pane_separator}_right_clear}" # right separator
    eval pane_border_format+="#{?pane_marked,#[default#,align=right#,reverse]\${pl33t_pl_${pane_separator}_right_opaque}#[noreverse],}" # marked
    pane_border_format+="}"
    # set pane border format
    tmux set -g pane-border-format "${pane_border_format}"
}

# status line modifications
StatusLineModding() {
    # track current status line
    local line_ndx=$1
    [[ ${line_ndx} -ne 0 ]] && local line_name="-line${line_ndx}"

    # status line template
    local status_format=''
    status_format+="#{T:@pl33t-status${line_name}-left-format}"
    status_format+="#{T:@pl33t-status${line_name}-centre-format}"
    status_format+="#{T:@pl33t-status${line_name}-right-format}"
    tmux set -g "status-format[${line_ndx}]" "${status_format}"

    local side
    for side in 'left' 'centre' 'right'; do
        # set status side format
        local status_side_format=''
        StatusSideBuilder
        tmux set -g @pl33t-status${line_name}-${side}-format "${status_side_format}"
    done
}

# status line left/centre/right side builder
StatusSideBuilder() {
    # status side segments parser
    IFS=,
    local side_segments_list=($(GetTmuxOption @pl33t-status${line_name}-${side}-segments))
    unset IFS

    # status side format header
    status_side_format+="#[align=${side}]"

    # status side segment builder
    local segment
    for segment in ${side_segments_list[@]}; do
        local segment_format=''
        if [[ ${segment} == 'winstatus' ]]; then
            WindowStatusModding
            status_side_format+='#{T:@pl33t-window-status-format}'
        else
            StatusSegmentBuilder
            status_side_format+="${segment_format}"
        fi
    done

    # status side format footer
    status_side_format+='#[default]'
}

# status line side segment builder
StatusSegmentBuilder() {
    # get current segment's settings
    IFS=,
    local segment_separator=($(GetTmuxOption @pl33t-status-segment-${segment}-separator))
    unset IFS
    StyleParser @pl33t-status-segment-${segment}-style
    local segment_fg="${fg:-#{E:@pl33t-status-fg\}}"
    local segment_bg="${bg:-#{E:@pl33t-status-bg\}}"
    local segment_attr="${attr}"

    # segment separators
    local -a segment_sep_format_list
    segment_sep_format_list[0]="#[fg=${segment_bg}#,bg=#{@pl33t-status-bg}${segment_attr}#,none]"
    segment_sep_format_list[1]="#[bg=${segment_bg}#,fg=#{@pl33t-status-bg}${segment_attr}#,none]"
    eval segment_sep_format_list[2]="\${pl33t_pl_${segment_separator[1]}_left_opaque}"
    eval segment_sep_format_list[3]="\${pl33t_pl_${segment_separator[1]}_right_opaque}"

    SepFormatPicker segment_sep_format_list[@] "${segment_separator[0]}"
    local segment_sep_left_format="${sep_format_picker_list[0]}"
    local segment_sep_right_format="${sep_format_picker_list[1]}"

    # segment format builder
    [[ -n ${tmp} ]] && segment_format+="#{?#{T:@pl33t-status-segment-${segment}-content},"
    segment_format+="${segment_sep_left_format}" # left separator
    segment_format+="#[fg=${segment_fg}#,bg=${segment_bg}${segment_attr}]" # style
    segment_format+="#{T:@pl33t-status-segment-${segment}-content}" # content
    segment_format+="${segment_sep_right_format}" # right separator
    [[ -n ${tmp} ]] && segment_format+=",}"
}

# window status modifications
WindowStatusModding() {
    # settings parser
    IFS=,
    local win_separator=($(GetTmuxOption @pl33t-window-status-separator))
    local win_cur_separator=($(GetTmuxOption @pl33t-window-status-current-separator))
    unset IFS

    # window status styles builder
    for style_name in '' 'current' 'activity' 'bell' 'last' 'silence'; do
        StyleParser @pl33t-window-status-${style_name:+${style_name}-}style
        eval local win_status_${style_name:+${style_name}_}bg="${bg}"
        eval local win_status_${style_name:+${style_name}_}attr="${attr}"
    done
    unset style_name

    # normal windows separators
    local -a win_sep_format_list
    win_sep_format_list[0]="#[fg=${win_status_bg}#,bg=#{E:@pl33t-status-bg}${win_status_attr}#,none]"
    win_sep_format_list[0]+="#{?#{window_last_flag},#[fg=${win_status_last_bg}],}"
    win_sep_format_list[0]+="#{?#{window_bell_flag},#[fg=${win_status_bell_bg}],}"
    win_sep_format_list[0]+="#{?#{window_activity_flag},#[fg=${win_status_activity_bg}],}"
    win_sep_format_list[0]+="#{?#{window_silence_flag},#[fg=${win_status_silence_bg}],}"

    win_sep_format_list[1]="#[bg=${win_status_bg}#,fg=#{E:@pl33t-status-bg}${win_status_attr}#,none]"
    win_sep_format_list[1]+="#{?#{window_last_flag},#[bg=${win_status_last_bg}],}"
    win_sep_format_list[1]+="#{?#{window_bell_flag},#[bg=${win_status_bell_bg}],}"
    win_sep_format_list[1]+="#{?#{window_activity_flag},#[bg=${win_status_activity_bg}],}"
    win_sep_format_list[1]+="#{?#{window_silence_flag},#[bg=${win_status_silence_bg}],}"

    eval win_sep_format_list[2]="\${pl33t_pl_${win_separator[2]}_left_opaque}"
    eval win_sep_format_list[3]="\${pl33t_pl_${win_separator[2]}_right_opaque}"

    local i side_list=(left right)
    for i in 0 1; do
        SepFormatPicker win_sep_format_list[@] "${win_separator[$i]}"
        eval local win_${side_list[$i]}_sep_left_format="\${sep_format_picker_list[0]}"
        eval local win_${side_list[$i]}_sep_right_format="\${sep_format_picker_list[1]}"
    done

    # current window separators
    local -a win_cur_sep_format_list
    win_cur_sep_format_list[0]="#[fg=${win_status_current_bg}#,bg=#{E:@pl33t-status-bg}${win_status_current_attr}#,none]"
    win_cur_sep_format_list[0]+="#{?#{window_bell_flag},#[fg=${win_status_bell_bg}],}"
    win_cur_sep_format_list[0]+="#{?#{window_activity_flag},#[fg=${win_status_activity_bg}],}"
    win_cur_sep_format_list[0]+="#{?#{window_silence_flag},#[fg=${win_status_silence_bg}],}"

    win_cur_sep_format_list[1]="#[bg=${win_status_current_bg}#,fg=#{E:@pl33t-status-bg}${win_status_current_attr}#,none]"
    win_cur_sep_format_list[1]+="#{?#{window_bell_flag},#[bg=${win_status_bell_bg}],}"
    win_cur_sep_format_list[1]+="#{?#{window_activity_flag},#[bg=${win_status_activity_bg}],}"
    win_cur_sep_format_list[1]+="#{?#{window_silence_flag},#[bg=${win_status_silence_bg}],}"

    eval win_cur_sep_format_list[2]="\${pl33t_pl_${win_cur_separator[1]}_left_opaque}"
    eval win_cur_sep_format_list[3]="\${pl33t_pl_${win_cur_separator[1]}_right_opaque}"

    SepFormatPicker win_cur_sep_format_list[@] "${win_cur_separator[0]}"
    local win_cur_sep_left_format="${sep_format_picker_list[0]}"
    local win_cur_sep_right_format="${sep_format_picker_list[1]}"

    # window status format builder
    local window_status_format=''

    # window status header
    window_status_format+="#[align=${side}]"
    # window status body
    window_status_format+="#{W:#[range=window|#{window_index}]"
    # normal windows
    window_status_format+="#{?#{m:*#I *A*,#{W:#I ,A }},${win_left_sep_left_format},${win_right_sep_left_format}}" # left separator
    window_status_format+="#[#{E:@pl33t-window-status-style}]" # default style
    window_status_format+="#{?#{window_last_flag},#[#{E:@pl33t-window-status-last-style}],}" # last style
    window_status_format+="#{?#{window_bell_flag},#[#{E:@pl33t-window-status-bell-style}],}" # bell style
    window_status_format+="#{?#{window_activity_flag},#[#{E:@pl33t-window-status-activity-style}],}" # activity style
    window_status_format+="#{?#{window_silence_flag},#[#{E:@pl33t-window-status-silence-style}],}" # silence style
    window_status_format+="#{T:@pl33t-window-status-content}" # content
    window_status_format+="#{?#{m:*#I *A*,#{W:#I ,A }},${win_left_sep_right_format},${win_right_sep_right_format}}" # right separator
    window_status_format+="#[norange#,default],"
    # current window
    window_status_format+="#[range=window|#{window_index}]"
    window_status_format+="${win_cur_sep_left_format}" # left separator
    window_status_format+="#[#{E:@pl33t-window-status-current-style}]" # default style
    window_status_format+="#{?#{window_bell_flag},#[#{E:@pl33t-window-status-bell-style}],}" # bell style
    window_status_format+="#{?#{window_activity_flag},#[#{E:@pl33t-window-status-activity-style}],}" # activity style
    window_status_format+="#{?#{window_silence_flag},#[#{E:@pl33t-window-status-silence-style}],}" # silence style
    window_status_format+="#{T:@pl33t-window-status-current-content}" # content
    window_status_format+="${win_cur_sep_right_format}" # right separator
    # window status footer
    window_status_format+='#[norange#,default]}'

    # set window status format
    tmux set -g @pl33t-window-status-format "${window_status_format}"
}

Main
