#!/bin/bash

#  _________________________
# | Notification with sound |
#  -------------------------

case $5 in
    LOW) paplay ~/.config/dunst/sounds/low.ogg ;;
    NORMAL) if [[ "$1" == "Vol:" || "$1" == "Bri:" ]]; then
                exit 1
            else
                paplay ~/.config/dunst/sounds/normal.ogg
            fi ;;
    CRITICAL) paplay ~/.config/dunst/sounds/critical.ogg ;;
esac

