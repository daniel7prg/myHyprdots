#!/bin/bash

#  _____________
# | Global vars |
#  -------------

# Colors Pywal
source "${HOME}/.cache/wal/colors.sh"

# theme var
gtkTheme=`gsettings get org.gnome.desktop.interface gtk-theme | sed "s/'//g"`
gtkMode=`gsettings get org.gnome.desktop.interface color-scheme | sed "s/'//g" | awk -F '-' '{print $2}'`

# hypr var
hypr_border=`hyprctl -j getoption decoration:rounding | jq '.int'`
hypr_width=`hyprctl -j getoption general:border_size | jq '.int'`

# read font size

fnt_override=`gsettings get org.gnome.desktop.interface font-name | sed "s/'//g" | grep Nerd`
fnt_override="configuration {font: \"${fnt_override}\";}"

# Current color scheme
current_theme=`grep -o "gtk-application.*" ~/.config/gtk-3.0/settings.ini | cut -d "=" -f 2`

# Rofi select color
color_override="element selected.normal {background-image: linear-gradient(90deg, $color3, $color6);} element selected.active {background-image: linear-gradient(90deg, $color1, $color2);}"
dconf=~/.config/rofi/conf/applauncher.rasi
wconf=~/.config/rofi/conf/activewin.rasi
sconf=~/.config/rofi/conf/wallselect.rasi
wifils=~/.config/rofi/conf/wifi.rasi
wifiky=~/.config/rofi/conf/wifiPSW.rasi

if [[ "$current_theme" -eq 0 ]]; then
    dconf=~/.config/rofi/conf/applauncher-light.rasi
    wconf=~/.config/rofi/conf/activewin-light.rasi
    sconf=~/.config/rofi/conf/wallselect-light.rasi
    wifils=~/.config/rofi/conf/wifi-light.rasi
    wifiky=~/.config/rofi/conf/wifiPSW-light.rasi
fi