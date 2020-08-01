#!/usr/bin/env bash

# Tmux pl33t theme

# main starting point
Main() {
    SanityCheck
    CURRENT_DIR="$(dirname $0)"
    source "${CURRENT_DIR}/scripts/helpers.sh"
    source "${CURRENT_DIR}/scripts/variables.sh"
    ApplyTheme
    Features
}

# sanity check
SanityCheck() {
    # Tmux version check
    if ! [[ "$(tmux -V)" =~ ^tmux\ (3\.[1-9]|[4-9]) ]]; then
        tmux display "$(basename $0): Tmux version 3.1+ needed"
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
    local feature features=(wttr publicip)
    for feature in ${features[@]}; do
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
        local segments_format=''
        SegmentBuilder @pl33t-pane-${pane_type}-border-segments
        tmux set -g @pl33t-pane-${pane_type}-border-format "${segments_format}"
    done
}

# status line modifications
StatusLineModding() {
    local line_ndx=$1   # track current status line
    local side status_format=''
    for side in 'left' 'centre' 'right'; do
        # status side templates
        local fg= bg= attr= tmp= length=
        StyleParser @pl33t-status-${line_ndx}-${side}-style
        status_format+="#[fg=${fg:-default}#,bg=${bg:-default}${attr:+#,${attr}}]" # style
        status_format+="#[push-default]"
        status_format+="#{T${length:+;${length}}:@pl33t-status-${line_ndx}-${side}-format}" # content
        status_format+="#[pop-default]"
        status_format+="#[norange#,default]"

        # status side segments builder
        local status_side_format=''
        local segments_format=''
        SegmentBuilder @pl33t-status-${line_ndx}-${side}-segments
        status_side_format+="${segments_format}"
        tmux set -g @pl33t-status-${line_ndx}-${side}-format "${status_side_format}"
    done
    tmux set -g "status-format[${line_ndx}]" "${status_format}"
}

# segment builder
SegmentBuilder() {
    local segment segments="$(GetTmuxOption $1)"
    for segment in ${segments//,/ }; do
        if [[ ${segment} == 'winstatus' ]]; then
            #[[ -z $(GetTmuxOption @pl33t-winstatus-format) ]] && WindowStatusModding
            WindowStatusModding
            segments_format+='#{T:@pl33t-winstatus-format}'
        else
            local fg= bg= attr= tmp= length=
            StyleParser @pl33t-segment-${segment}-style
            local lsep_ndx=() rsep_ndx=() sep_shape= clear=
            SepFormatParser @pl33t-segment-${segment}-separator

            # segment separators
            local -a segment_sep_formats
            segment_sep_formats[0]="#[${attr:+${attr}#,}none#,fg=${bg:-default}#,bg=default]"
            if [[ -n ${clear} ]]; then
                segment_sep_formats[1]="${segment_sep_formats[0]}"
                eval segment_sep_formats[2]="\${pl33t_pl_${sep_shape}_left_clear}#[none]"
                eval segment_sep_formats[3]="\${pl33t_pl_${sep_shape}_right_clear}#[none]"
            else
                segment_sep_formats[1]="#[${attr:+${attr}#,}none#,fg=${bg:-default}#,bg=default#,reverse]"
                eval segment_sep_formats[2]="\${pl33t_pl_${sep_shape}_left_opaque}#[none]"
                eval segment_sep_formats[3]="\${pl33t_pl_${sep_shape}_right_opaque}#[none]"
            fi

            local segment_lsep_format="${segment_sep_formats[${lsep_ndx[0]}]}${segment_sep_formats[${lsep_ndx[1]}]}"
            local segment_rsep_format="${segment_sep_formats[${rsep_ndx[0]}]}${segment_sep_formats[${rsep_ndx[1]}]}"

            # segment format builder
            [[ -n ${tmp} ]] && segments_format+="#{?#{T:@pl33t-segment-${segment}-content},"
            segments_format+="${segment_lsep_format}" # left separator
            segments_format+="#[fg=${fg:-default}#,bg=${bg:-default}${attr:+#,${attr}}]" # style
            segments_format+="#{T${length:+;${length}}:@pl33t-segment-${segment}-content}" # content
            segments_format+="${segment_rsep_format}" # right separator
            [[ -n ${tmp} ]] && segments_format+=",}"
        fi
    done
}

# window status modifications
WindowStatusModding() {
    # window status styles builder
    for style_name in 'other' 'current' 'activity' 'bell' 'last' 'silence'; do
        local fg= bg= attr= tmp= length=
        StyleParser @pl33t-winstatus-${style_name}-style
        eval local winstatus_${style_name}_bg="${bg}"
        eval local winstatus_${style_name}_attr="${attr:+${attr}#,}"
    done
    unset style_name

    # normal windows separators
    local -a win_sep_formats
    win_sep_formats[0]="#[${winstatus_other_attr}none#,fg=${winstatus_other_bg}#,bg=default]"
    win_sep_formats[0]+="#{?#{window_last_flag},#[fg=${winstatus_last_bg}],}"
    win_sep_formats[0]+="#{?#{window_activity_flag},#[fg=${winstatus_activity_bg}],}"
    win_sep_formats[0]+="#{?#{window_silence_flag},#[fg=${winstatus_silence_bg}],}"
    win_sep_formats[0]+="#{?#{window_bell_flag},#[fg=${winstatus_bell_bg}],}"

    win_sep_formats[1]="#[${winstatus_other_attr}none#,fg=${winstatus_other_bg}#,bg=default#,reverse]"
    win_sep_formats[1]+="#{?#{window_last_flag},#[fg=${winstatus_last_bg}],}"
    win_sep_formats[1]+="#{?#{window_activity_flag},#[fg=${winstatus_activity_bg}],}"
    win_sep_formats[1]+="#{?#{window_silence_flag},#[fg=${winstatus_silence_bg}],}"
    win_sep_formats[1]+="#{?#{window_bell_flag},#[fg=${winstatus_bell_bg}],}"

    local lsep_ndx=() rsep_ndx=() sep_shape= clear=
    SepFormatParser @pl33t-winstatus-other-separator
    eval win_sep_formats[2]="\${pl33t_pl_${sep_shape}_left_opaque}#[none]"
    eval win_sep_formats[3]="\${pl33t_pl_${sep_shape}_right_opaque}#[none]"

    local lwin_lsep_format="${win_sep_formats[${lsep_ndx[0]}]}${win_sep_formats[${lsep_ndx[1]}]}"
    local lwin_rsep_format="${win_sep_formats[${rsep_ndx[0]}]}${win_sep_formats[${rsep_ndx[1]}]}"
    local rwin_lsep_format="${win_sep_formats[${lsep_ndx[2]}]}${win_sep_formats[${lsep_ndx[3]}]}"
    local rwin_rsep_format="${win_sep_formats[${rsep_ndx[2]}]}${win_sep_formats[${rsep_ndx[3]}]}"

    # current window separators
    local -a cwin_sep_formats
    cwin_sep_formats[0]="#[${winstatus_current_attr}none#,fg=${winstatus_current_bg}#,bg=default]"
    cwin_sep_formats[0]+="#{?#{window_activity_flag},#[fg=${winstatus_activity_bg}],}"
    cwin_sep_formats[0]+="#{?#{window_silence_flag},#[fg=${winstatus_silence_bg}],}"
    cwin_sep_formats[0]+="#{?#{window_bell_flag},#[fg=${winstatus_bell_bg}],}"

    cwin_sep_formats[1]="#[${winstatus_current_attr}none#,fg=${winstatus_current_bg}#,bg=default#,reverse]"
    cwin_sep_formats[1]+="#{?#{window_activity_flag},#[fg=${winstatus_activity_bg}],}"
    cwin_sep_formats[1]+="#{?#{window_silence_flag},#[fg=${winstatus_silence_bg}],}"
    cwin_sep_formats[1]+="#{?#{window_bell_flag},#[fg=${winstatus_bell_bg}],}"

    local lsep_ndx=() rsep_ndx=() sep_shape= clear=
    SepFormatParser @pl33t-winstatus-current-separator
    eval cwin_sep_formats[2]="\${pl33t_pl_${sep_shape}_left_opaque}#[none]"
    eval cwin_sep_formats[3]="\${pl33t_pl_${sep_shape}_right_opaque}#[none]"

    local cwin_lsep_format="${cwin_sep_formats[${lsep_ndx[0]}]}${cwin_sep_formats[${lsep_ndx[1]}]}"
    local cwin_rsep_format="${cwin_sep_formats[${rsep_ndx[0]}]}${cwin_sep_formats[${rsep_ndx[1]}]}"

    # window status format builder
    local winstatus_format=''
    # normal windows
    winstatus_format+="#{W:#[range=window|#{window_index}]"
    winstatus_format+="#{?#{m:*#I *A*,#{W:#I ,A }},${lwin_lsep_format},${rwin_lsep_format}}" # left separator
    winstatus_format+="#[#{E:@pl33t-winstatus-other-style}]" # default style
    winstatus_format+="#{?#{window_last_flag},#[#{E:@pl33t-winstatus-last-style}],}" # last style
    winstatus_format+="#{?#{window_activity_flag},#[#{E:@pl33t-winstatus-activity-style}],}" # activity style
    winstatus_format+="#{?#{window_silence_flag},#[#{E:@pl33t-winstatus-silence-style}],}" # silence style
    winstatus_format+="#{?#{window_bell_flag},#[#{E:@pl33t-winstatus-bell-style}],}" # bell style
    winstatus_format+="#{T:@pl33t-winstatus-other-content}" # content
    winstatus_format+="#{?#{m:*#I *A*,#{W:#I ,A }},${lwin_rsep_format},${rwin_rsep_format}}" # right separator
    winstatus_format+="#[norange default],"
    # current window
    winstatus_format+="#[range=window|#{window_index}]"
    winstatus_format+="${cwin_lsep_format}" # left separator
    winstatus_format+="#[#{E:@pl33t-winstatus-current-style}]" # default style
    winstatus_format+="#{?#{window_activity_flag},#[#{E:@pl33t-winstatus-activity-style}],}" # activity style
    winstatus_format+="#{?#{window_silence_flag},#[#{E:@pl33t-winstatus-silence-style}],}" # silence style
    winstatus_format+="#{?#{window_bell_flag},#[#{E:@pl33t-winstatus-bell-style}],}" # bell style
    winstatus_format+="#{T:@pl33t-winstatus-current-content}" # content
    winstatus_format+="${cwin_rsep_format}" # right separator
    winstatus_format+='#[norange default]}'

    # set window status format
    tmux set -g @pl33t-winstatus-format "${winstatus_format}"
}

Main
