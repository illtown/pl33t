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
    # pane border template
    local pane_border_format='#{?pane_active,'
    pane_border_format+='#{T:@pl33t-pane-active-border-format},'
    pane_border_format+='#{T:@pl33t-pane-other-border-format}}'
    tmux set -g pane-border-format "${pane_border_format}"

    local pane_type
    for pane_type in 'active' 'other'; do
        local pane_format=''
        PaneTypeBuilder
        tmux set -g @pl33t-pane-${pane_type}-border-format "${pane_format}"
    done
}

# pane type builder
PaneTypeBuilder() {
    # pane type segments parser
    IFS=,
    local segments_list=($(GetTmuxOption @pl33t-pane-${pane_type}-border-segments))
    unset IFS

    # pane segments builder
    local segments_format=''
    SegmentBuilder
    pane_format+="${segments_format}"
}

# status line modifications
StatusLineModding() {
    # track current status line
    local line_ndx=$1

    # status line template
    local status_format=''
    status_format+="#{T:@pl33t-status-${line_ndx}-left-format}"
    status_format+="#{T:@pl33t-status-${line_ndx}-centre-format}"
    status_format+="#{T:@pl33t-status-${line_ndx}-right-format}"
    tmux set -g "status-format[${line_ndx}]" "${status_format}"

    local side
    for side in 'left' 'centre' 'right'; do
        local status_side_format=''
        StatusSideBuilder
        tmux set -g @pl33t-status-${line_ndx}-${side}-format "${status_side_format}"
    done
}

# status line left/centre/right side builder
StatusSideBuilder() {
    # status side segments parser
    IFS=,
    local segments_list=($(GetTmuxOption @pl33t-status-${line_ndx}-${side}-segments))
    unset IFS

    # status side format header
    if [[ ${line_ndx} -eq 0 && ${side} =~ ^(left|right)$ ]]; then
        status_side_format+="#[align=${side} range=${side}]"
    else
        status_side_format+="#[align=${side}]"
    fi

    # status side segments builder
    local segments_format=''
    SegmentBuilder
    status_side_format+="${segments_format}"

    # status side format footer
    if [[ ${line_ndx} -eq 0 && ${side} =~ ^(left|right)$ ]]; then
        status_side_format+='#[norange default]'
    else
        status_side_format+='#[default]'
    fi
}

# segment builder
SegmentBuilder() {
    local segment
    for segment in ${segments_list[@]}; do
        if [[ ${segment} == 'winstatus' ]]; then
            [[ -z $(GetTmuxOption @pl33t-window-status-format) ]] && WindowStatusModding
            segments_format+='#{T:@pl33t-window-status-format}'
        else
            # get current segment's settings
            IFS=,
            local segment_separator=($(GetTmuxOption @pl33t-segment-${segment}-separator))
            unset IFS
            StyleParser @pl33t-segment-${segment}-style

            # segment separators
            local -a segment_sep_format_list
            segment_sep_format_list[0]="#[${attr:+${attr}#,}none#,fg=${bg:-default}#,bg=default]"
            if [[ -n ${clear} ]]; then
                segment_sep_format_list[1]="${segment_sep_format_list[0]}"
                eval segment_sep_format_list[2]="\${pl33t_pl_${segment_separator[1]}_left_clear}#[none]"
                eval segment_sep_format_list[3]="\${pl33t_pl_${segment_separator[1]}_right_clear}#[none]"
            else
                segment_sep_format_list[1]="#[${attr:+${attr}#,}none#,fg=${bg:-default}#,bg=default#,reverse]"
                eval segment_sep_format_list[2]="\${pl33t_pl_${segment_separator[1]}_left_opaque}#[none]"
                eval segment_sep_format_list[3]="\${pl33t_pl_${segment_separator[1]}_right_opaque}#[none]"
            fi

            SepFormatPicker segment_sep_format_list[@] "${segment_separator[0]}"
            local segment_sep_left_format="${sep_format_picker_list[0]}"
            local segment_sep_right_format="${sep_format_picker_list[1]}"

            # segment format builder
            [[ -n ${tmp} ]] && segments_format+="#{?#{T:@pl33t-segment-${segment}-content},"
            segments_format+="${segment_sep_left_format}" # left separator
            segments_format+="#[fg=${fg:-default}#,bg=${bg:-default}${attr:+#,${attr}}]" # style
            segments_format+="#{T:@pl33t-segment-${segment}-content}" # content
            segments_format+="${segment_sep_right_format}" # right separator
            [[ -n ${tmp} ]] && segments_format+=",}"
        fi
    done
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
        eval local win_status_${style_name:+${style_name}_}attr="${attr:+#,${attr}}"
    done
    unset style_name

    # normal windows separators
    local -a win_sep_format_list
    win_sep_format_list[0]="#[fg=${win_status_bg}#,bg=#{E:@pl33t-status-bg}${win_status_attr}#,none]"
    win_sep_format_list[0]+="#{?#{window_last_flag},#[fg=${win_status_last_bg}],}"
    win_sep_format_list[0]+="#{?#{window_activity_flag},#[fg=${win_status_activity_bg}],}"
    win_sep_format_list[0]+="#{?#{window_silence_flag},#[fg=${win_status_silence_bg}],}"
    win_sep_format_list[0]+="#{?#{window_bell_flag},#[fg=${win_status_bell_bg}],}"

    win_sep_format_list[1]="#[bg=${win_status_bg}#,fg=#{E:@pl33t-status-bg}${win_status_attr}#,none]"
    win_sep_format_list[1]+="#{?#{window_last_flag},#[bg=${win_status_last_bg}],}"
    win_sep_format_list[1]+="#{?#{window_activity_flag},#[bg=${win_status_activity_bg}],}"
    win_sep_format_list[1]+="#{?#{window_silence_flag},#[bg=${win_status_silence_bg}],}"
    win_sep_format_list[1]+="#{?#{window_bell_flag},#[bg=${win_status_bell_bg}],}"

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
    win_cur_sep_format_list[0]+="#{?#{window_activity_flag},#[fg=${win_status_activity_bg}],}"
    win_cur_sep_format_list[0]+="#{?#{window_silence_flag},#[fg=${win_status_silence_bg}],}"
    win_cur_sep_format_list[0]+="#{?#{window_bell_flag},#[fg=${win_status_bell_bg}],}"

    win_cur_sep_format_list[1]="#[bg=${win_status_current_bg}#,fg=#{E:@pl33t-status-bg}${win_status_current_attr}#,none]"
    win_cur_sep_format_list[1]+="#{?#{window_activity_flag},#[bg=${win_status_activity_bg}],}"
    win_cur_sep_format_list[1]+="#{?#{window_silence_flag},#[bg=${win_status_silence_bg}],}"
    win_cur_sep_format_list[1]+="#{?#{window_bell_flag},#[bg=${win_status_bell_bg}],}"

    eval win_cur_sep_format_list[2]="\${pl33t_pl_${win_cur_separator[1]}_left_opaque}"
    eval win_cur_sep_format_list[3]="\${pl33t_pl_${win_cur_separator[1]}_right_opaque}"

    SepFormatPicker win_cur_sep_format_list[@] "${win_cur_separator[0]}"
    local win_cur_sep_left_format="${sep_format_picker_list[0]}"
    local win_cur_sep_right_format="${sep_format_picker_list[1]}"

    # window status format builder
    local window_status_format=''

    # window status header
    window_status_format+="#[align=${side}]"
    # normal windows
    window_status_format+="#{W:#[range=window|#{window_index}]"
    window_status_format+="#{?#{m:*#I *A*,#{W:#I ,A }},${win_left_sep_left_format},${win_right_sep_left_format}}" # left separator
    window_status_format+="#[#{E:@pl33t-window-status-style}]" # default style
    window_status_format+="#{?#{window_last_flag},#[#{E:@pl33t-window-status-last-style}],}" # last style
    window_status_format+="#{?#{window_activity_flag},#[#{E:@pl33t-window-status-activity-style}],}" # activity style
    window_status_format+="#{?#{window_silence_flag},#[#{E:@pl33t-window-status-silence-style}],}" # silence style
    window_status_format+="#{?#{window_bell_flag},#[#{E:@pl33t-window-status-bell-style}],}" # bell style
    window_status_format+="#{T:@pl33t-window-status-content}" # content
    window_status_format+="#{?#{m:*#I *A*,#{W:#I ,A }},${win_left_sep_right_format},${win_right_sep_right_format}}" # right separator
    window_status_format+="#[norange default],"
    # current window
    window_status_format+="#[range=window|#{window_index}]"
    window_status_format+="${win_cur_sep_left_format}" # left separator
    window_status_format+="#[#{E:@pl33t-window-status-current-style}]" # default style
    window_status_format+="#{?#{window_activity_flag},#[#{E:@pl33t-window-status-activity-style}],}" # activity style
    window_status_format+="#{?#{window_silence_flag},#[#{E:@pl33t-window-status-silence-style}],}" # silence style
    window_status_format+="#{?#{window_bell_flag},#[#{E:@pl33t-window-status-bell-style}],}" # bell style
    window_status_format+="#{T:@pl33t-window-status-current-content}" # content
    window_status_format+="${win_cur_sep_right_format}" # right separator
    window_status_format+='#[norange default]}'

    # set window status format
    tmux set -g @pl33t-window-status-format "${window_status_format}"
}

Main
