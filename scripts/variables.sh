#!/usr/bin/env bash

# Tmux pl33t theme default settings

# tmux colors include: black, red, green, yellow, blue, magenta, cyan, white;
# bright variants: brightred, brightgreen, brightyellow;
# colour0 to colour255 from the 256-colour set;
# default for the default colour;
# terminal for the terminal default colour;
# or a hexadecimal RGB string such as ‘#ffffff’

# ---- theme dominant color ----
tmux set -go @pl33t-accent-color 'blue'

# ---- pane modding ----
tmux set -go pane-border-status 'top'

# normal panes
tmux set -go @pl33t-pane-border-content ' #{pane_index} #{pane_title} '
tmux set -go @pl33t-pane-border-separator 'triangle'
tmux set -go @pl33t-pane-border-style 'fg=brightblack'
tmux set -Fg pane-border-style '#{E:@pl33t-pane-border-style}'

# active pane
tmux set -go @pl33t-pane-active-border-content ' #{pane_current_command} '
tmux set -go @pl33t-pane-active-border-separator 'triangle'
tmux set -go @pl33t-pane-active-border-style 'fg=#{@pl33t-accent-color}'
tmux set -Fg pane-active-border-style '#{E:@pl33t-pane-active-border-style}'

# pane indicators style
tmux set -Fg display-panes-colour 'brightblack'
tmux set -Fg display-panes-active-colour '#{@pl33t-accent-color}'

# ---- general status line modding ----
# OS window title string
tmux set -go set-titles-string 'tmux:#h:#S:#I[#W]'

# messages style
tmux set -Fg message-style 'fg=black,bg=#{@pl33t-accent-color}'
tmux set -Fg message-command-style 'fg=#{@pl33t-accent-color},bg=black,bright'

# mode style
tmux set -Fg mode-style 'fg=black,bg=#{@pl33t-accent-color}'

# status line main style
tmux set -go @pl33t-status-fg 'white'
tmux set -go @pl33t-status-bg 'black'
tmux set -Fg status-style 'fg=#{@pl33t-status-fg},bg=#{@pl33t-status-bg}'

# ammount of pre-configured status lines: 2 through 5 or anything else for 1.
# you still need to use tmux native 'status' option to display additional lines.
tmux set -go @pl33t-status-lines '1'

# ---- status segments modding ----
# host segment
tmux set -go @pl33t-status-segment-host-content '  #{host_short} '
tmux set -go @pl33t-status-segment-host-separator '-right,triangle'
tmux set -go @pl33t-status-segment-host-style 'fg=black,bg=#{@pl33t-accent-color}'
# session segment
tmux set -go @pl33t-status-segment-session-content ' #{session_name} '
tmux set -go @pl33t-status-segment-session-separator 'right,triangle'
tmux set -go @pl33t-status-segment-session-style 'fg=black,bg=yellow'
# window segment
tmux set -go @pl33t-status-segment-window-content '  #{window_name} '
tmux set -go @pl33t-status-segment-window-separator 'right,triangle'
tmux set -go @pl33t-status-segment-window-style  'fg=black,bg=white'
# time segment
tmux set -go @pl33t-status-segment-time-content '  %H:%M:%S '
tmux set -go @pl33t-status-segment-time-separator 'left,triangle'
tmux set -go @pl33t-status-segment-time-style 'fg=black,bg=white'
# date segment
tmux set -go @pl33t-status-segment-date-content '   %d-%b-%y '
tmux set -go @pl33t-status-segment-date-separator 'left-,triangle'
tmux set -go @pl33t-status-segment-date-style 'fg=black,bg=#{@pl33t-accent-color}'
# segments location
tmux set -go @pl33t-status-0-left-segments 'host,session,window'
tmux set -go @pl33t-status-0-centre-segments 'winstatus' # 'winstatus' is reserved segment name
tmux set -go @pl33t-status-0-right-segments 'time,date'

# ---- window status modding ----
# normal windows
tmux set -go @pl33t-window-status-content ' #{window_index} #{window_name} '
# separator directions for left-from-current and right-from-current windows
tmux set -go @pl33t-window-status-separator 'left,right,triangle'
tmux set -go @pl33t-window-status-style 'fg=black,bg=colour241'

# current window
tmux set -go @pl33t-window-status-current-content ' #{window_index} #{window_name} '
tmux set -go @pl33t-window-status-current-separator 'left-right,triangle'
tmux set -go @pl33t-window-status-current-style 'fg=black,bg=#{@pl33t-accent-color}'

# window supplementary styles
tmux set -go @pl33t-window-status-activity-style 'fg=black,bg=green'
tmux set -go @pl33t-window-status-bell-style 'fg=brightyellow,bg=red,blink'
tmux set -go @pl33t-window-status-last-style 'fg=black,bg=colour245'
tmux set -go @pl33t-window-status-silence-style 'fg=black,bg=magenta'

# ---- feature scripts settings ----
# wttr settings. use #{E:@pl33t-features-wttr} in status format variables to display
tmux set -go @pl33t-features-wttr-toggle 'off'
tmux set -go @pl33t-features-wttr-interval '3600'
tmux set -go @pl33t-features-wttr-options ''

# publicip settings. use #{E:@pl33t-features-publicip} in status format variables to display
tmux set -go @pl33t-features-publicip-toggle 'off'
tmux set -go @pl33t-features-publicip-interval '600'
tmux set -go @pl33t-features-publicip-options ''

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
# opaque only glyphs (ok for status line, but not for pane borders)
pl33t_pl_ice_right_opaque=' '          # \ue0c8
pl33t_pl_ice_left_opaque=' '           # \ue0ca
pl33t_pl_digital1_right_opaque=' '     # \ue0c4
pl33t_pl_digital1_left_opaque=' '      # \ue0c5
pl33t_pl_digital2_right_opaque=' '     # \ue0c6
pl33t_pl_digital2_left_opaque=' '      # \ue0c7
pl33t_pl_trapezoid_right_opaque=''     # \ue0d2
pl33t_pl_trapezoid_left_opaque=''      # \ue0d4
