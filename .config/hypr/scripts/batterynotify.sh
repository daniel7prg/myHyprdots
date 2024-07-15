#!/bin/bash

#  _______________________
# | Battery System Notify |
#  -----------------------

# Current icon theme
icontheme=$(grep -o "gtk-icon-theme-name.*" ~/.config/gtk-3.0/settings.ini | cut -d "=" -f 2)

# Battery vars
BAT=$(ls /sys/class/power_supply | grep BAT | head -n 1)
BATSTATUS=$(cat /sys/class/power_supply/${BAT}/status)
BATVAL=$(cat /sys/class/power_supply/${BAT}/capacity)
BATICON=$(geticons "battery" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)

if [[ "$BATSTATUS" == "Discharging" ]];then
    if [ "$BATVAL" -lt 40 ];then
        dunstify -i $BATICON "Battery Level" "Battery less than 40% 󰁾 - Please connect your laptop"
    elif [ "$BATVAL" -lt 25 ];then
        dunstify -u low -i $BATICON "Battery Level" "Battery less than 25% 󰁺 - Please connect your laptop"
    elif [ "$BATVAL" -lt 10 ];then
        dunstify -u critical -i $BATICON "Battery Level" "Battery less than 10% 󰁺 - Please connect your laptop"
    fi
fi
