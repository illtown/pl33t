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
    local features_list=(wttr publicip testfunc)
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
    case $(GetTmuxOption pane-border-status) in
        'top'|'bottom' )
            local sep_shape=$(GetTmuxOption @pl33t-pane-border-sep-shape)
            local pane_border_format

            eval pane_border_format+="#{?pane_marked,#[reverse]\${pl33t_pl_${sep_shape}_left_opaque}#[noreverse],}" # marked pane
            pane_border_format+='#{?pane_active,'
            # active pane border
            pane_border_format+="#[#{E:@pl33t-pane-active-border-style}]" # WA for 'align' not being inherited
            eval pane_border_format+="\${pl33t_pl_${sep_shape}_left_opaque}"
            pane_border_format+="#[reverse]#{T:@pl33t-pane-active-border-content}#[noreverse]"
            eval pane_border_format+="\${pl33t_pl_${sep_shape}_right_opaque}"
            pane_border_format+=","
            # normal pane border
            pane_border_format+="#[#{E:@pl33t-pane-border-style}]" # WA for 'align' not being inherited
            eval pane_border_format+="\${pl33t_pl_${sep_shape}_left_clear}"
            pane_border_format+="#{T:@pl33t-pane-border-content}"
            eval pane_border_format+="\${pl33t_pl_${sep_shape}_right_clear}"
            pane_border_format+="}"
            eval pane_border_format+="#{?pane_marked,#[default#,align=right#,reverse]\${pl33t_pl_${sep_shape}_right_opaque}#[noreverse],}"
            # set pane border format
            tmux set -g pane-border-format "${pane_border_format}"
        ;;
    esac
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
        # check if window status segment should go to this side
        if [[ ${line_ndx} -eq 0 && "$(GetTmuxOption '@pl33t-window-status-position')" == "${side}" ]]; then
            tmux set -g @pl33t-status-${side}-format '#{T:@pl33t-window-status-format}'
            WindowStatusModding
            continue
        fi
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
    local side_content_list=($(GetTmuxOption @pl33t-status${line_name}-${side}-content))
    local side_fg_list=($(GetTmuxOption @pl33t-status${line_name}-${side}-fg))
    local side_bg_list=($(GetTmuxOption @pl33t-status${line_name}-${side}-bg))
    local side_attr_list=($(GetTmuxOption @pl33t-status${line_name}-${side}-attr))
    local side_sep_dir_list=($(GetTmuxOption @pl33t-status${line_name}-${side}-sep-dir))
    local side_sep_shape_list=($(GetTmuxOption @pl33t-status${line_name}-${side}-sep-shape))
    unset IFS

    # status side format header
    status_side_format+="#[align=${side}#,range=${side}]"

    # status side segment builder
    local i
    for (( i=0; i<${#side_content_list[@]}; i++ )); do
        # skip drawing empty segment
        [[ -z ${side_content_list[$i]} ]] && continue
        local segment_format=''
        StatusSegmentBuilder
        status_side_format+="${segment_format}"
    done

    # status side format footer
    status_side_format+='#[norange#,default]'
}

# status line side segment builder
StatusSegmentBuilder() {
    # get current segment style ...
    local segment_fg="${side_fg_list[$i]:-#{E:@pl33t-status-fg\}}"
    local segment_bg="${side_bg_list[$i]:-#{E:@pl33t-status-bg\}}"
    local segment_attr="${side_attr_list[$i]}"
    # ... and separator
    local segment_sep_dir="${side_sep_dir_list[$i]}"
    local segment_sep_shape="${side_sep_shape_list[$i]:-triangle}"

    # segment separators
    local -a segment_sep_format_list
    segment_sep_format_list[0]="#[fg=${segment_bg}#,bg=#{@pl33t-status-bg}#,${segment_attr}#,none]"
    segment_sep_format_list[1]="#[fg=#{@pl33t-status-bg}#,bg=${segment_bg}#,${segment_attr}#,none]"
    eval segment_sep_format_list[2]="\${pl33t_pl_${segment_sep_shape}_left_opaque}"
    eval segment_sep_format_list[3]="\${pl33t_pl_${segment_sep_shape}_right_opaque}"

    SepFormatBuilder segment_sep_format_list[@] "${segment_sep_dir}"
    local segment_sep_left_format="${sep_format_builder_list[0]}"
    local segment_sep_right_format="${sep_format_builder_list[1]}"

    # segment format builder
    segment_format+="${segment_sep_left_format}"
    segment_format+="#[fg=${segment_fg}#,bg=${segment_bg}#,${segment_attr}]"
    segment_format+="${side_content_list[$i]}"
    segment_format+="${segment_sep_right_format}"
}

# window status modifications
WindowStatusModding() {
    # settings parser
    local win_sep_shape=$(GetTmuxOption @pl33t-window-status-sep-shape)
    IFS=,
    local win_sep_dir_list=($(GetTmuxOption @pl33t-window-status-sep-dir))
    unset IFS
    local win_cur_sep_shape=$(GetTmuxOption @pl33t-window-status-current-sep-shape)
    local win_cur_sep_dir=$(GetTmuxOption @pl33t-window-status-current-sep-dir)

    # normal windows separators
    local -a win_sep_format_list
    win_sep_format_list[0]='#[fg=#{E:@pl33t-window-status-bg}#,bg=#{E:@pl33t-status-bg}#,#{E:@pl33t-window-status-attr}#,none]'
    win_sep_format_list[0]+='#{?#{window_last_flag},#[fg=#{E:@pl33t-window-status-last-bg}],}'
    win_sep_format_list[0]+='#{?#{window_bell_flag},#[fg=#{E:@pl33t-window-status-bell-bg}],}'
    win_sep_format_list[0]+='#{?#{window_activity_flag},#[fg=#{E:@pl33t-window-status-activity-bg}],}'
    win_sep_format_list[0]+='#{?#{window_silence_flag},#[fg=#{E:@pl33t-window-status-silence-bg}],}'

    win_sep_format_list[1]='#[fg=#{E:@pl33t-status-bg}#,bg=#{E:@pl33t-window-status-bg}#,#{E:@pl33t-window-status-attr}#,none]'
    win_sep_format_list[1]+='#{?#{window_last_flag},#[bg=#{E:@pl33t-window-status-last-bg}],}'
    win_sep_format_list[1]+='#{?#{window_bell_flag},#[bg=#{E:@pl33t-window-status-bell-bg}],}'
    win_sep_format_list[1]+='#{?#{window_activity_flag},#[bg=#{E:@pl33t-window-status-activity-bg}],}'
    win_sep_format_list[1]+='#{?#{window_silence_flag},#[bg=#{E:@pl33t-window-status-silence-bg}],}'

    eval win_sep_format_list[2]="\${pl33t_pl_${win_sep_shape}_left_opaque}"
    eval win_sep_format_list[3]="\${pl33t_pl_${win_sep_shape}_right_opaque}"

    local i side_list=(left right)
    for i in 0 1; do
        SepFormatBuilder win_sep_format_list[@] "${win_sep_dir_list[$i]}"
        eval local win_${side_list[$i]}_sep_left_format="\${sep_format_builder_list[0]}"
        eval local win_${side_list[$i]}_sep_right_format="\${sep_format_builder_list[1]}"
    done

    # current window separators
    local -a win_cur_sep_format_list
    win_cur_sep_format_list[0]='#[fg=#{E:@pl33t-window-status-current-bg}#,bg=#{E:@pl33t-status-bg}#,#{E:@pl33t-window-status-current-attr}#,none]'
    win_cur_sep_format_list[0]+='#{?#{window_bell_flag},#[fg=#{E:@pl33t-window-status-bell-bg}],}'
    win_cur_sep_format_list[0]+='#{?#{window_activity_flag},#[fg=#{E:@pl33t-window-status-activity-bg}],}'
    win_cur_sep_format_list[0]+='#{?#{window_silence_flag},#[fg=#{E:@pl33t-window-status-silence-bg}],}'

    win_cur_sep_format_list[1]='#[fg=#{E:@pl33t-status-bg}#,bg=#{E:@pl33t-window-status-current-bg}#,#{E:@pl33t-window-status-current-attr}#,none]'
    win_cur_sep_format_list[1]+='#{?#{window_bell_flag},#[bg=#{E:@pl33t-window-status-bell-bg}],}'
    win_cur_sep_format_list[1]+='#{?#{window_activity_flag},#[bg=#{E:@pl33t-window-status-activity-bg}],}'
    win_cur_sep_format_list[1]+='#{?#{window_silence_flag},#[bg=#{E:@pl33t-window-status-silence-bg}],}'

    eval win_cur_sep_format_list[2]="\${pl33t_pl_${win_cur_sep_shape}_left_opaque}"
    eval win_cur_sep_format_list[3]="\${pl33t_pl_${win_cur_sep_shape}_right_opaque}"

    SepFormatBuilder win_cur_sep_format_list[@] "${win_cur_sep_dir}"
    local win_cur_sep_left_format="${sep_format_builder_list[0]}"
    local win_cur_sep_right_format="${sep_format_builder_list[1]}"

    # window status format builder
    local window_status_format=''

    # window status header
    window_status_format+="#[align=#{@pl33t-window-status-position}]"
    # window status body
    window_status_format+="#{W:#[range=window|#{window_index}]"
    # normal windows
    window_status_format+="#{?#{<:#I,#{W:,#I}},${win_left_sep_left_format},${win_right_sep_left_format}}" # left separator
    window_status_format+="#[#{E:@pl33t-window-status-style}]" # default style
    window_status_format+="#{?#{window_last_flag},#[#{E:@pl33t-window-status-last-style}],}" # last style
    window_status_format+="#{?#{window_bell_flag},#[#{E:@pl33t-window-status-bell-style}],}" # bell style
    window_status_format+="#{?#{window_activity_flag},#[#{E:@pl33t-window-status-activity-style}],}" # activity style
    window_status_format+="#{?#{window_silence_flag},#[#{E:@pl33t-window-status-silence-style}],}" # silence style
    window_status_format+="#{T:@pl33t-window-status-content}" # content
    window_status_format+="#{?#{<:#I,#{W:,#I}},${win_left_sep_right_format},${win_right_sep_right_format}}" # right separator
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
