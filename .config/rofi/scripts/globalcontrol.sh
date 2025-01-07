#!/bin/bash

#  _____________
# | Global vars |
#  -------------

# Messages
WARNING_TL="_WARNING_"
WARNING_MS="Close all windows "
CHANGE_MS="Changing to"
MODE_MS="Light"

# Current theme
current_theme=`grep -o "gtk-application.*" ~/.config/gtk-3.0/settings.ini | cut -d "=" -f 2`
iconDark='Papirus-Dark'
iconLight='Papirus-Light'

# Rofi select color
dconf=~/.config/rofi/conf/applauncher.rasi
wconf=~/.config/rofi/conf/activewin.rasi

# Dunst theme
dunst_theme=~/.cache/wal/dunstrc-dark

if [[ "$current_theme" -eq 0 ]]; then
    dconf=~/.config/rofi/conf/applauncher-light.rasi
    wconf=~/.config/rofi/conf/activewin-light.rasi
    dunst_theme=~/.cache/wal/dunstrc-light
    MODE_MS="Dark"
fi