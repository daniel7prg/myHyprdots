#!/bin/bash

#  _____________
# | Global vars |
#  -------------

# Messages
WARNING_TL="_WARNING_"
WARNING_MS="Close all windows "
CHANGE_MS="Changing to"
MODE_MS="Light"
color_mode="dark"
color_scheme="prefer-dark"
set_scheme=0
swt_color_mode="light"
swt_color_scheme="prefer-light"

# Current theme
current_theme=`grep -o "gtk-application.*" ~/.config/gtk-3.0/settings.ini | cut -d "=" -f 2`
iconDark='Papirus-Dark'
iconLight='Papirus-Light'
current_wal=$(cat ~/.cache/wal/colors.json | jq ".wallpaper" | sed 's/"//g')
current_icon=$iconDark
swt_current_icon=$iconLight

# Rofi select color
wconf=~/.config/rofi/conf/activewin.rasi

if [[ "$current_theme" -eq 0 ]]; then
    # Switch Part
    MODE_MS="Dark"
    set_scheme=1
    swt_current_icon=$iconDark
    swt_color_scheme="prefer-dark"
    swt_color_mode="dark"
    # Wal Part
    current_icon=$iconLight
    color_scheme="prefer-light"
    color_mode="light"
fi