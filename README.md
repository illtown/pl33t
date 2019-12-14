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
Default theme settings are located in [variables.sh](scripts/variables.sh) file. You may override them in your `tmux.conf`.
