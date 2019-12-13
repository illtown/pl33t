#!/usr/bin/env bash

# tmux colors include: black, red, green, yellow, blue, magenta, cyan, white;
# bright variants: brightred, brightgreen, brightyellow;
# colour0 to colour255 from the 256-colour set;
# default for the default colour;
# terminal for the terminal default colour;
# or a hexadecimal RGB string such as ‘#ffffff’

# ---- theme dominant color ----
tmux set -go @pl33t-accent-color "blue"

# ---- pane modding ----
tmux set -g pane-border-status "top"
# separator shape: triangle, hcircle, flame, bottomtriangle, toptriangle
tmux set -go @pl33t-pane-border-sep-shape "triangle"
tmux set -go @pl33t-pane-border-content " #{pane_index} #{pane_title} "
tmux set -go @pl33t-pane-active-border-content " #{pane_current_command} "

# pane borders style
tmux set -go @pl33t-pane-border-style 'fg=brightblack'
tmux set -go @pl33t-pane-active-border-style "fg=#{@pl33t-accent-color}"
tmux set -Fg pane-border-style "#{E:@pl33t-pane-border-style}"
tmux set -Fg pane-active-border-style "#{E:@pl33t-pane-active-border-style}"

# pane indicators style
tmux set -Fg display-panes-colour "brightblack"
tmux set -Fg display-panes-active-colour "#{@pl33t-accent-color}"

# ---- general status line modding ----
# OS window title string
tmux set -g set-titles-string "tmux:#h:#S:#I[#W]"

# messages style
tmux set -Fg message-style "fg=black,bg=#{@pl33t-accent-color}"
tmux set -Fg message-command-style "fg=#{@pl33t-accent-color},bg=black,bright"

# mode style
tmux set -Fg mode-style "fg=black,bg=#{@pl33t-accent-color}"

# status line main style
tmux set -go @pl33t-status-fg "white"
tmux set -go @pl33t-status-bg "black"
tmux set -Fg status-style "fg=#{@pl33t-status-fg},bg=#{@pl33t-status-bg}"

# ammount of status lines: 2 through 5 or anything else for 1.
tmux set -go @pl33t-status-lines '1'

# ---- status-left modding ----
tmux set -go @pl33t-status-left-length "40"
tmux set -go @pl33t-status-left-content "  #{host_short} , #{session_name} ,  #{window_name} "
# status-left style
tmux set -go @pl33t-status-left-fg "black,black,black"
tmux set -go @pl33t-status-left-bg "#{@pl33t-accent-color},yellow,white"
tmux set -go @pl33t-status-left-attr ""
# separator direction: (left|right)[-(left|right)]
tmux set -go @pl33t-status-left-sep-dir "-right,right,right"
tmux set -go @pl33t-status-left-sep-shape "" # defaults to triangle

# ---- status-right modding ----
tmux set -go @pl33t-status-right-length "40"
tmux set -go @pl33t-status-right-content "  %H:%M:%S ,   %d-%b-%y "
# status-right style
tmux set -go @pl33t-status-right-fg "black,black"
tmux set -go @pl33t-status-right-bg "white,#{@pl33t-accent-color}"
tmux set -go @pl33t-status-right-attr ""
# separator direction: (left|right)[-(left|right)]
tmux set -go @pl33t-status-right-sep-dir "left,left-"
tmux set -go @pl33t-status-right-sep-shape "" # defaults to triangle

# ---- window status modding ----
# choose from left, centre, right.
tmux set -go @pl33t-window-status-position "centre"

# normal windows
tmux set -go @pl33t-window-status-content " #{window_index} #{window_name} "
tmux set -go @pl33t-window-status-sep-shape "triangle"
# separator directions for left-from-current and right-from-current windows
tmux set -go @pl33t-window-status-sep-dir "left-left,right-right"

# current window
tmux set -go @pl33t-window-status-current-content " #{window_index} #{window_name} "
tmux set -go @pl33t-window-status-current-sep-shape "triangle"
tmux set -go @pl33t-window-status-current-sep-dir "left-right"

# window status styles
tmux set -go @pl33t-window-status-fg "black"
tmux set -go @pl33t-window-status-bg "colour241"
tmux set -go @pl33t-window-status-attr ""
tmux set -go @pl33t-window-status-current-fg "black"
tmux set -go @pl33t-window-status-current-bg "#{@pl33t-accent-color}"
tmux set -go @pl33t-window-status-current-attr ""

# window supplementary styles
tmux set -go @pl33t-window-status-activity-fg "black"
tmux set -go @pl33t-window-status-activity-bg "green"
tmux set -go @pl33t-window-status-activity-attr ""
tmux set -go @pl33t-window-status-bell-fg "brightyellow"
tmux set -go @pl33t-window-status-bell-bg "red"
tmux set -go @pl33t-window-status-bell-attr "blink"
tmux set -go @pl33t-window-status-last-fg "black"
tmux set -go @pl33t-window-status-last-bg "colour245"
tmux set -go @pl33t-window-status-last-attr ""
tmux set -go @pl33t-window-status-silence-fg "black"
tmux set -go @pl33t-window-status-silence-bg "magenta"
tmux set -go @pl33t-window-status-silence-attr ""

# window status styles builder
for style_name in '' '-current' '-activity' '-bell' '-last' '-silence'; do
    tmux set -go @pl33t-window-status${style_name}-style \
        "fg=#{E:@pl33t-window-status${style_name}-fg}#,bg=#{E:@pl33t-window-status${style_name}-bg}#,#{E:@pl33t-window-status${style_name}-attr}"
done
unset style_name

# ---- additional status lines ----
pl33t_status_lines=$(GetTmuxOption @pl33t-status-lines)
if [[ ${pl33t_status_lines} =~ ^[2-5]$ ]]; then
    for (( i=1; i<${pl33t_status_lines}; i++ )); do
        for pos in 'left' 'centre' 'right'; do
            # pre-configure status line
            tmux set -go @pl33t-status-line${i}-${pos}-length "40"
            tmux set -go @pl33t-status-line${i}-${pos}-content ""
            # status line style
            tmux set -go @pl33t-status-line${i}-${pos}-fg "black"
            tmux set -go @pl33t-status-line${i}-${pos}-bg "white"
            tmux set -go @pl33t-status-line${i}-${pos}-attr ""
            # separator direction: (left|right)[-(left|right)]
            tmux set -go @pl33t-status-line${i}-${pos}-sep-dir "left-right"
            tmux set -go @pl33t-status-line${i}-${pos}-sep-shape "triangle"
        done
    done
fi
unset i pos

# ---- feature scripts settings ----
# wttr settings. use #{E:@pl33t-features-wttr} in status format variables to display
tmux set -go @pl33t-features-wttr-toggle "off"
tmux set -go @pl33t-features-wttr-interval "3600"
tmux set -go @pl33t-features-wttr-options ""

# publicip settings. use #{E:@pl33t-features-publicip} in status format variables to display
tmux set -go @pl33t-features-publicip-toggle "off"
tmux set -go @pl33t-features-publicip-interval "600"
tmux set -go @pl33t-features-publicip-options ""

# ---- powerline symbols ----
# For the best experience nerd-fonts family suggested.
pl33t_pl_triangle_right_opaque=''      # \ue0b0
pl33t_pl_triangle_right_clear=''       # \ue0b1
pl33t_pl_triangle_left_opaque=''       # \ue0b2
pl33t_pl_triangle_left_clear=''        # \ue0b3
# powerline extra
pl33t_pl_hcircle_right_opaque=''       # \ue0b4
pl33t_pl_hcircle_right_clear=''        # \ue0b5
pl33t_pl_hcircle_left_opaque=''        # \ue0b6
pl33t_pl_hcircle_left_clear=''         # \ue0b7

pl33t_pl_trapezoid_right_opaque=''     # \ue0d2
pl33t_pl_trapezoid_left_opaque=''      # \ue0d4
# below symbols have extra space added or they get cut otherwise.
pl33t_pl_bottomtriangle_right_opaque=' '   # \ue0b8
pl33t_pl_bottomtriangle_right_clear=' '    # \ue0b9
pl33t_pl_bottomtriangle_left_opaque=' '    # \ue0ba
pl33t_pl_bottomtriangle_left_clear=' '     # \ue0bb
pl33t_pl_toptriangle_right_opaque=' '      # \ue0bc
pl33t_pl_toptriangle_right_clear=' '       # \ue0bd
pl33t_pl_toptriangle_left_opaque=' '       # \ue0be
pl33t_pl_toptriangle_left_clear=' '        # \ue0bf

pl33t_pl_flame_right_opaque=' '        # \ue0c0
pl33t_pl_flame_right_clear=' '         # \ue0c1
pl33t_pl_flame_left_opaque=' '         # \ue0c2
pl33t_pl_flame_left_clear=' '          # \ue0c3
pl33t_pl_ice_right_opaque=' '          # \ue0c8
pl33t_pl_ice_left_opaque=' '           # \ue0ca
pl33t_pl_digital1_right_opaque=' '     # \ue0c4
pl33t_pl_digital1_left_opaque=' '      # \ue0c5
pl33t_pl_digital2_right_opaque=' '     # \ue0c6
pl33t_pl_digital2_left_opaque=' '      # \ue0c7
