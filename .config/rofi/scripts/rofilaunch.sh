#!/bin/bash

#  ______________
# | Rofi Control |
#  --------------

## Global vars
source $HOME/.config/rofi/scripts/globalcontrol.sh

# read font size
fnt_override=`gsettings get org.gnome.desktop.interface font-name | sed "s/'//g"`
fnt_override="configuration {font: \"${fnt_override}\";}"

# read theme icon
icon_override=`gsettings get org.gnome.desktop.interface icon-theme | sed "s/'//g"`
icon_override="configuration {icon-theme: \"${icon_override}\";}"

# rofi action
case $1 in
    -d)  rofi -show drun -theme-str "${fnt_override}" -theme-str "${icon_override}" ;;
    -w)  rofi -show window -theme-str "${fnt_override}" -theme-str "${icon_override}" -config "${wconf}" ;;
    -h)  echo -e "rofilaunch.sh [action]\nwhere action,"
        echo "d :  drun mode"
        echo "w :  window mode"
        exit 0 ;;
    *)  echo "Command not found" ;;
esac
