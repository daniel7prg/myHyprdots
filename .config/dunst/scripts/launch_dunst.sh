#!/bin/bash

#  ____________________
# | Notification theme |
#  --------------------

## Global vars
source $HOME/.config/rofi/scripts/globalcontrol.sh

if [[ "$current_theme" -eq 1 ]]; then
    sleep 0.1
    dunst -conf "~/.cache/wal/dunstrc-dark" &
else
    sleep 0.1
    dunst -conf "~/.cache/wal/dunstrc-light" &
fi