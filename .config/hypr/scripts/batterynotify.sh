#!/bin/bash

#  _______________________
# | Battery System Notify |
#  -----------------------

export DISPLAY=:1
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

# Current icon theme
icontheme=$(grep -o "gtk-icon-theme-name.*" ~/.config/gtk-3.0/settings.ini | cut -d "=" -f 2)

# Battery vars
BAT=$(ls /sys/class/power_supply | grep BAT | head -n 1)
BATSTATUS=$(cat /sys/class/power_supply/${BAT}/status)
BATVAL=$(cat /sys/class/power_supply/${BAT}/capacity)
BATICON=$(geticons "battery" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)

if [[ "$BATSTATUS" == "Discharging" ]];then
    if [ "$BATVAL" -eq 45 ];then
        notify-send -i $BATICON "Battery Level" "Battery equal to 45% 󰁾 - Please connect your laptop"
    elif [ "$BATVAL" -eq 30 ];then
        notify-send -u low -i $BATICON "Battery Level" "Battery equal to 30% 󰁺 - Please connect your laptop"
    elif [ "$BATVAL" -lt 20 ];then
        notify-send -u critical -i $BATICON "Battery Level" "Battery less than 20% 󰁺 - Please connect your laptop"
    fi
fi