#!/bin/bash

#  _______________________
# | Battery System Notify |
#  -----------------------

get_status(){
  BAT=$(/usr/bin/ls /sys/class/power_supply | grep BAT | head -n 1)
  BATSTATUS="$(/usr/bin/cat /sys/class/power_supply/${BAT}/status)"
  BATVAL="$(/usr/bin/cat /sys/class/power_supply/${BAT}/capacity)"

  if [[ "$BATSTATUS" == "Discharging" ]];then
    if [ "$BATVAL" -lt 50 ];then
      dunstify -i $HOME/.config/dunst/icons/battery_50.png "Bateria menor al 50% 󰁾"
    elif [ "$BATVAL" -lt 35 ];then
      dunstify -i $HOME/.config/dunst/icons/recharge_battery.png "Bateria menor al 30% 󰁼 - Conecte su laptop"
    elif [ "$BATVAL" -lt 15 ];then
      dunstify -u low -i $HOME/.config/dunst/icons/battery_low.png "Bateria menor al 10% 󰁺 - Conecte su laptop"
    fi
  fi
}

get_status
