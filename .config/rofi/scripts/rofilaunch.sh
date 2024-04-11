#!/bin/bash

#  ______________
# | Rofi Control |
#  --------------

source $HOME/.config/rofi/scripts/globalcontrol.sh

# read hypr theme border

wind_border=$(( hypr_border * 2 ))
elem_border=`[ $hypr_border -eq 0 ] && echo "10" || echo $(( hypr_border * 2 ))`
r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"

# read hypr theme icon

icon_override=`gsettings get org.gnome.desktop.interface icon-theme | sed "s/'//g"`
icon_override="configuration {icon-theme: \"${icon_override}\";}"

# read wallpaper
current_wal=$(echo "$(swww query)" | grep -o 'image:.*'| awk '{print $2}')
wal_override="inputbar {background-image: url('${current_wal}.png', width);}"

# rofi action
case $1 in
    d)  rofi -show drun -theme-str "${color_override}" -theme-str "${fnt_override}" -theme-str "${r_override}" -theme-str "${icon_override}" -theme-str "${wal_override}" -config "${dconf}" ;;
    w)  rofi -show window -theme-str "${color_override}" -theme-str "${fnt_override}" -theme-str "${r_override}" -theme-str "${icon_override}" -config "${wconf}" ;;
    h)  echo -e "rofilaunch.sh [action]\nwhere action,"
        echo "d :  drun mode"
        echo "w :  window mode"
        exit 0 ;;
    *)  r_mode="drun" ;;
esac
