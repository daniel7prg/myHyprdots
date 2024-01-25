#!/usr/bin/env sh

# set variables

source ${HOME}/.config/rofi/scripts/globalcontrol.sh
RofiConf="${HOME}/.config/rofi/themeselect.rasi"
wallPath="${HOME}/.config/swww/wallpapers/"

# scale for monitor x res
x_monres=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
monitor_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')
x_monres=$(( x_monres * 17 / monitor_scale ))

# set rofi override

#Style 2
elem_border=$(( hypr_border * 3 ))
r_override="element{border-radius:${elem_border}px;} listview{columns:6;spacing:100px;} element{padding:0px;orientation:vertical;} element-icon{size:${x_monres}px;border-radius:0px;} element-text{padding:20px;}"

# launch rofi menu
RofiSel=$( find "${wallPath}" -type f \( -iname "*.gif" \) -exec basename {} \; | sort | while read rfile
do
    echo -en "$rfile\x00icon\x1f${wallPath}/${rfile}.png\n"
done | rofi -dmenu -theme-str "${r_override}" -config "${RofiConf}")


# apply wallpaper
if [ ! -z "${RofiSel}" ] ; then
	if [ "$(hyprctl clients | grep -c 'Window')" -eq "0" ]; then
        swww img ${wallPath}/${RofiSel}
		wal -q -i "$wallPath/$RofiSel"
		eww reload
		ln -sf ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc
		killall xdg-desktop-portal-gtk
		killall polkit-gnome-authentication-agent-1
		killall dunst
		ln -sf ~/.cache/wal/Dracula-purple-solid.kvconfig ~/.config/Kvantum/Dracula-purple-solid/Dracula-purple-solid.kvconfig
		dunstify "t1" -a "${RofiSel}" -i "${wallPath}/${RofiSel}" -r 91190 -t 2200
    else
        dunstify -u critical "ADVERTENCIA - Cierre todas las ventanas antes de cambiar de tema"
    fi
fi
