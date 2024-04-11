#!/bin/bash

#  _________________________
# | Notification with sound |
#  -------------------------

# Volumen control variables
vol=`pamixer $srce --get-volume | cat`
barv=$(seq -s "." $(($vol / 15)) | sed 's/[0-9]//g')

# Brightness control variables
brightness=`brightnessctl info | grep -oP "(?<=\()\d+(?=%)" | cat`
barb=$(seq -s "." $(($brightness / 15)) | sed 's/[0-9]//g')

case $5 in
    LOW) paplay ~/.config/dunst/sounds/low.ogg ;;
    NORMAL) if [[ "$1" == "$vol$barv" ||  $1 == "$brightness$barb" ]]; then
                paplay ~/.config/dunst/sounds/control.ogg
            else
                paplay ~/.config/dunst/sounds/normal.ogg
            fi ;;
    CRITICAL) paplay ~/.config/dunst/sounds/critical.ogg ;;
esac

