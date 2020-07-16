#!/usr/bin/env bash

# Tmux pl33t theme default settings

# tmux colors include: black, red, green, yellow, blue, magenta, cyan, white;
# bright variants: brightred, brightgreen, brightyellow;
# colour0 to colour255 from the 256-colour set;
# default for the default colour;
# terminal for the terminal default colour;
# or a hexadecimal RGB string such as ‘#ffffff’

# ---- theme colors ----
tmux set -go @pl33t-color-accent 'blue'

# ---- pane modding ----
tmux set -go pane-border-status 'top'
# active pane
tmux set -go @pl33t-segment-apane-content ' #{pane_current_command} '
tmux set -go @pl33t-segment-apane-separator 'left-right,triangle'
tmux set -go @pl33t-segment-apane-style 'fg=black,bg=#{@pl33t-color-accent}'
tmux set -go @pl33t-pane-active-border-segments 'apane'
tmux set -Fg pane-active-border-style 'fg=#{@pl33t-color-accent}'
# other panes
tmux set -go @pl33t-segment-pane-content ' #{pane_index} #{pane_title} '
tmux set -go @pl33t-segment-pane-separator 'left-right,triangle'
tmux set -go @pl33t-segment-pane-style 'fg=brightblack,bg=black'
tmux set -go @pl33t-pane-other-border-segments 'pane'
tmux set -Fg pane-border-style 'fg=brightblack'
# pane indicators style
tmux set -Fg display-panes-active-colour '#{@pl33t-color-accent}'
tmux set -Fg display-panes-colour 'brightblack'

# ---- general status line modding ----
# OS window title string
tmux set -go set-titles-string 'tmux:#h:#S:#I[#W]'
# messages style
tmux set -Fg message-style 'fg=black,bg=#{@pl33t-color-accent}'
tmux set -Fg message-command-style 'fg=#{@pl33t-color-accent},bg=black,bright'
# mode style
tmux set -Fg mode-style 'fg=black,bg=#{@pl33t-color-accent}'
# status line main style
tmux set -go @pl33t-status-fg 'white'
tmux set -go @pl33t-status-bg 'black'
tmux set -Fg status-style 'fg=#{@pl33t-status-fg},bg=#{@pl33t-status-bg}'

# ---- status lines modding ----
# ammount of pre-configured status lines: 2 through 5 or anything else for 1.
# you still need to use tmux native 'status' option to display additional lines.
tmux set -go @pl33t-status-lines '1'
# host segment
tmux set -go @pl33t-segment-host-content '  #{host_short} '
tmux set -go @pl33t-segment-host-separator '-right,triangle'
tmux set -go @pl33t-segment-host-style 'fg=black,bg=#{@pl33t-color-accent}'
# session segment
tmux set -go @pl33t-segment-session-content ' #{session_name} '
tmux set -go @pl33t-segment-session-separator 'right,triangle'
tmux set -go @pl33t-segment-session-style 'fg=black,bg=yellow'
# window segment
tmux set -go @pl33t-segment-window-content '  #{window_name} '
tmux set -go @pl33t-segment-window-separator 'right,triangle'
tmux set -go @pl33t-segment-window-style  'fg=black,bg=white'
# time segment
tmux set -go @pl33t-segment-time-content '  %H:%M:%S '
tmux set -go @pl33t-segment-time-separator 'left,triangle'
tmux set -go @pl33t-segment-time-style 'fg=black,bg=white'
# date segment
tmux set -go @pl33t-segment-date-content '   %d-%b-%y '
tmux set -go @pl33t-segment-date-separator 'left-,triangle'
tmux set -go @pl33t-segment-date-style 'fg=black,bg=#{@pl33t-color-accent}'
# segments location
tmux set -go @pl33t-status-0-left-segments 'host,session,window'
tmux set -go @pl33t-status-0-centre-segments 'winstatus' # 'winstatus' is reserved segment name
tmux set -go @pl33t-status-0-right-segments 'time,date'

# ---- window status modding ----
# current window
tmux set -go @pl33t-winstatus-current-content ' #{window_index} #{window_name} '
tmux set -go @pl33t-winstatus-current-separator 'left-right,triangle'
tmux set -go @pl33t-winstatus-current-style 'fg=black,bg=#{@pl33t-color-accent}'
# other windows
tmux set -go @pl33t-winstatus-other-content ' #{window_index} #{window_name} '
# separator directions for left-from-current and right-from-current windows
tmux set -go @pl33t-winstatus-other-separator 'left,right,triangle'
tmux set -go @pl33t-winstatus-other-style 'fg=black,bg=colour241'
# window supplementary styles
tmux set -go @pl33t-winstatus-activity-style 'fg=black,bg=green'
tmux set -go @pl33t-winstatus-bell-style 'fg=brightyellow,bg=red,blink'
tmux set -go @pl33t-winstatus-last-style 'fg=black,bg=colour245'
tmux set -go @pl33t-winstatus-silence-style 'fg=black,bg=magenta'

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
# For the best experience nerd-fonts family recommended.
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
# opaque-only glyphs
pl33t_pl_ice_right_opaque=' '          # \ue0c8
pl33t_pl_ice_left_opaque=' '           # \ue0ca
pl33t_pl_digital1_right_opaque=' '     # \ue0c4
pl33t_pl_digital1_left_opaque=' '      # \ue0c5
pl33t_pl_digital2_right_opaque=' '     # \ue0c6
pl33t_pl_digital2_left_opaque=' '      # \ue0c7
pl33t_pl_trapezoid_right_opaque=''     # \ue0d2
pl33t_pl_trapezoid_left_opaque=''      # \ue0d4
