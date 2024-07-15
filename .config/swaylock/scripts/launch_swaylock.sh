#!/bin/bash

#  ________________________
# | Swaylock Current Theme |
#  ------------------------

source $HOME/.config/rofi/scripts/globalcontrol.sh

if [[ "$current_theme" -eq 1 ]]; then
    sleep 0.1
    swaylock -C $HOME/.cache/wal/lock-dark
else
    sleep 0.1
    swaylock -C $HOME/.cache/wal/lock-light
fi
