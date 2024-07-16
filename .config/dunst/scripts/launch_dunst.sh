#!/bin/bash

#  ____________________
# | Notification theme |
#  --------------------

## Global vars
source $HOME/.config/rofi/scripts/globalcontrol.sh

if [[ "$current_theme" -eq 1 ]]; then
    usleep 10000
    dunst -conf "~/.cache/wal/dunstrc-dark" &
else
    usleep 10000
    dunst -conf "~/.cache/wal/dunstrc-light" &
fi