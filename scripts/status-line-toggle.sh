#!/usr/bin/env bash

for opt in $@; do
    [[ $(tmux display -p '#{status}') != ${opt} ]] && { tmux set status ${opt}; exit; }
done
