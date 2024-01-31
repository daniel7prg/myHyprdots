#!/bin/bash

# Volumen control variables
vol=`pamixer $srce --get-volume | cat`
bar=$(seq -s "." $(($vol / 15)) | sed 's/[0-9]//g')

# Brightness control variables
brightness=`brightnessctl info | grep -oP "(?<=\()\d+(?=%)" | cat`
brightinfo=$(brightnessctl info | awk -F "'" '/Device/ {print $2}')

if [[ $1 == "$vol$bar" || $1 == "$brightness$bar" ]]; then
    paplay ~/.config/dunst/sounds/control.ogg
elif [[ $5 == "LOW" ]]; then
    paplay ~/.config/dunst/sounds/low.ogg
elif [[ $5 == "NORMAL" ]]; then
    paplay ~/.config/dunst/sounds/normal.ogg
elif [[ $5 == "CRITICAL" ]]; then
    paplay ~/.config/dunst/sounds/critical.ogg
fi

