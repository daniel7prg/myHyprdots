#!/bin/bash

#  ____________________
# | Brightness Control |
#  --------------------

icontheme=$(grep -o "gtk-icon-theme-name.*" ~/.config/gtk-3.0/settings.ini | cut -d "=" -f 2)

notify_brgt (){
    bright_level=$(brightnessctl get)
    if [[ $bright_level -gt 50 ]]; then icon="brightness-high"
    else icon="brightness-low"; fi
    bright_icon=$(geticons "$icon" -s 16 -t "$icontheme" --no-fallbacks | head -n 1)
    if [[ -z "$bright_icon" ]]; then
        bright_icon=$(geticons "display-brightness-symbolic" -s 16 -t "$icontheme" --no-fallbacks | head -n 1)
        if [[ -z "$bright_icon" ]]; then
            bright_icon=$(geticons "display-brightness-symbolic" -s 16 -t "Adwaita" --no-fallbacks | head -n 1); fi
    fi
    notify-send "t3" -a "Bri:" "${bright_level}%" -h int:value:$bright_level -i $bright_icon -r 91190 -t 800
}

if [[ "$1" == "-i" ]]; then
    brightnessctl -q set +5%
    notify_brgt
elif [[ "$1" == "-d" ]]; then
    brightnessctl -q set 5%-
    notify_brgt
fi