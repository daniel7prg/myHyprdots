#!/bin/bash

#  __________________
# | Select Wallpaper |
#  ------------------

# set variables

source ${HOME}/.config/rofi/scripts/globalcontrol.sh
wallPath=~/wallpapers/

# scale for monitor x res

x_monres=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
monitor_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')
x_monres=$(( x_monres * 17 / monitor_scale ))

# set rofi override

#Style 2
elem_border=$(( hypr_border * 2 ))
r_override="window {border: ${hypr_width}px; border-radius: ${elem_border}px;} element{border-radius:${elem_border}px;}"

# launch rofi menu
RofiSel=$( find "${wallPath}" -type f \( -iname "*.gif" \) -exec basename {} \; | sort | while read rfile
do
    echo -en "$rfile\x00icon\x1f${wallPath}/${rfile}.png\n"
done | rofi -dmenu -theme-str "${color_override}" -theme-str "${r_override}" -config "${sconf}")


# apply wallpaper
if [ ! -z "${RofiSel}" ] ; then
    if [ "$(hyprctl clients | grep -c 'Window')" -eq "0" ]; then
        swww img ${wallPath}/${RofiSel}
        #swww img ${wallPath}/${RofiSel} --transition-type wipe --transition-duration 2
        wal -q -i "$wallPath/$RofiSel"
        eww reload
        killall xdg-desktop-portal-gtk
        killall polkit-gnome-authentication-agent-1
        killall dunst
        cp ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc
        /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
        if [[ "$current_theme" -eq "0" ]]; then
                sed -i -e '445, 454 s/background/foreground/' -e '461s/background/foreground/' ~/.config/dunst/dunstrc
                sed -i -e '446, 455 s/foreground/background/' -e '462s/foreground/background/' ~/.config/dunst/dunstrc
                #sed -i -e '5s/foreground/background/' -e '6s/background/foreground/' ~/.config/foot/foot.ini
        fi
        dunstify "t1" -a "${RofiSel}" -i "${wallPath}/${RofiSel}" -r 91190 -t 2200

    else
        dunstify -u critical "ADVERTENCIA - Cierre todas las ventanas antes de cambiar de tema" -t 3600
    fi
fi
