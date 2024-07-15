#!/bin/bash

#  ________________________
# | Swaylock Current Theme |
#  ------------------------

## Global vars
source $HOME/.config/rofi/scripts/globalcontrol.sh

## Num row
rows=2

if [[ "$current_theme" -eq 1 ]]; then
    sleep 0.1
    wlogout -b $rows -p layer-shell -C ~/.config/wlogout/dark-theme.css
else
    sleep 0.1
    wlogout -b $rows -p layer-shell -C ~/.config/wlogout/light-theme.css
fi
