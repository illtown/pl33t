# pl33t
Powerline-extra enabled theme for Tmux.
## Installation
### with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @plugin 'illtown/pl33t'

Hit `prefix + I` to fetch the plugin and source it.

### manual

Clone the repo:

    $ git clone https://github.com/illtown/pl33t ~/clone/path

Add this line to the bottom of `.tmux.conf`:

    run ~/clone/path/pl33t.tmux

Reload TMUX environment:

    # type this in terminal
    $ tmux source-file ~/.tmux.conf

## Dependencies

To run this theme you need:

* sed utility
* tmux version 3+
* powerline enabled fonts ([nerdfonts](https://www.nerdfonts.com) recommended)

## Customization
Default theme settings are located in [variables.sh](scripts/variables.sh) file and have `@pl33t-` prefix. You may override them in your `tmux.conf`.
### status lines
At the beginning pl33t checks `@pl33t-status-lines` variable, which tells how many status lines it's going to pre-configure (tmux allows you to have upto 5 status lines).
Then, each line gets divided into 3 parts: left, centre and right. Pl33t fills tmux `status-format[x]` variables to achieve that:
```
status-format[0] "#{T:@pl33t-status-left-format}#{T:@pl33t-status-centre-format}#{T:@pl33t-status-right-format}"
status-format[1] "#{T:@pl33t-status-line1-left-format}#{T:@pl33t-status-line1-centre-format}#{T:@pl33t-status-line1-right-format}"
```
Pl33t then introduces new level of abstraction - segments, which are the building blocks for these left, centre and right format options.
The process of configuring status lines looks like this:
  * define segments and its parameters
  * fill `@pl33t-status-(left|centre|right)-segments` variables with comma-separated lists of segment names. For status lines other than the default you must add `-lineX-` prefix, where X is in 1-4 range.
### segments
Each segment consists of 3 variables:
  * `@pl33t-status-segment-<name>-content`. Defines the segment content
  * `@pl33t-status-segment-<name>-separator`. Segment separator settings consisting of 2 parameters: direction and shape
  * `@pl33t-status-segment-<name>-style`. Corresponds to tmux style settings.

You may choose any segment name you want as long as it gets referenced under `@pl33t-status-*-segments` variables.

There is one reserved segment name - `winstatus`, which deals with window list and has its own set of `@pl33t-window-status-*` variables.
### examples
Try adding this to your `tmux.conf`:
```
# ---- tmux-pl33t ----
# status line segments
# copy-mode indicator
set -g @pl33t-status-segment-mode-content "#{?#{pane_in_mode},  ,}"
set -g @pl33t-status-segment-mode-separator 'left,triangle'
set -g @pl33t-status-segment-mode-style "fg=black,bg=green,tmp"
# zoom indicator
set -g @pl33t-status-segment-zoom-content "#{?#{window_zoomed_flag},  ,}"
set -g @pl33t-status-segment-zoom-separator 'left,triangle'
set -g @pl33t-status-segment-zoom-style "fg=black,bg=magenta,tmp"
# prefix indicator
set -g @pl33t-status-segment-prefix-content "#{?#{client_prefix}, ,}"
set -g @pl33t-status-segment-prefix-separator 'left-right,triangle'
set -g @pl33t-status-segment-prefix-style "fg=black,bg=red,tmp"
# status line segments
set -g @pl33t-status-right-segments 'prefix,zoom,mode,time,date'
```
This example shows how to define your own segments and the use of `tmp` style parameter (pl33t-specific), which hides the segment if its content is zero or empty.
