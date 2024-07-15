#!/bin/bash

#  _________________________
# | Notification with sound |
#  -------------------------

case $5 in
    LOW) paplay ~/.config/dunst/sounds/low.ogg ;;
    NORMAL) vol=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}'| sed 's/%//')
            bright=$(brightnessctl get)
            if [[ "$1" == "Vol: $vol%" || "$1" == "Bri: $bright%" ]]; then
                paplay ~/.config/dunst/sounds/control.ogg
            else
                paplay ~/.config/dunst/sounds/normal.ogg
            fi ;;
    CRITICAL) paplay ~/.config/dunst/sounds/critical.ogg ;;
esac

