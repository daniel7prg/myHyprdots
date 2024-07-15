#!/bin/bash

#  ____________________
# | Brightness Control |
#  --------------------

icontheme=$(grep -o "gtk-icon-theme-name.*" ~/.config/gtk-3.0/settings.ini | cut -d "=" -f 2)

notify_brgt (){
    bright_level=$(brightnessctl get)
    bright_icon=$(geticons "brightnesssettings" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)
    dunstify "t2" -a "Bri: ${bright_level}%" -h int:value:$bright_level -i $bright_icon -r 91190 -t 800
}

if [[ "$1" == "-i" ]]; then
    brightnessctl -q set +5%
    notify_brgt
elif [[ "$1" == "-d" ]]; then
    brightnessctl -q set 5%-
    notify_brgt
fi