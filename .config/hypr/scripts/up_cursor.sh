#!/bin/bash

#  _____________________
# | Update cursor theme |
#  ---------------------

THEME_CURSOR=$(gsettings get org.gnome.desktop.interface cursor-theme | sed "s/'//g")
SIZE_CURSOR=$(gsettings get org.gnome.desktop.interface cursor-size)

info_gui(){
    dunstify "Cursor theme" "Configuring cursor to Hyprland " -t 1500
    sleep 2
    pkexec sed -i "s/Inherits=.*/Inherits=$THEME_CURSOR/" /usr/share/icons/default/index.theme
    theme_ver=$?
    if [[ $theme_ver -ne 0 ]]; then exit 0; fi
    sleep 1
    dunstify "Cursor theme" "Configuring cursor to Display Manager 󰗽" -t 1500
    sleep 2
    pkexec sed -i "s/CursorSize=.*/CursorSize=$SIZE_CURSOR/" /etc/sddm.conf
    theme_ver=$?
    if [[ $theme_ver -ne 0 ]]; then exit 0; fi
    sed -i -e "s/env = XCURSOR_SIZE,.*/env = XCURSOR_SIZE,$SIZE_CURSOR/" -e "s/env = HYPRCURSOR_SIZE,.*/env = HYPRCURSOR_SIZE,$SIZE_CURSOR/" ~/.config/hypr/conf/env.conf
}

info_term(){
    echo "Configuring cursor to Hyprland "
    sleep 1
    sudo sed -i "s/Inherits=.*/Inherits=$THEME_CURSOR/" /usr/share/icons/default/index.theme
    echo "Configuring cursor to Display Manager 󰗽"
    sleep 1
    sudo sed -i "s/CursorSize=.*/CursorSize=$SIZE_CURSOR/" /etc/sddm.conf
    sed -i -e "s/env = XCURSOR_SIZE,.*/env = XCURSOR_SIZE,$SIZE_CURSOR/" -e "s/env = HYPRCURSOR_SIZE,.*/env = HYPRCURSOR_SIZE,$SIZE_CURSOR/" ~/.config/hypr/conf/env.conf
}

if [[ "$1" == "-g" ]]; then
    info_gui
    dunstify "DONE!!" "-  - 'Reboot' or 'Logout' to apply changes"
else
    info_term
    echo " DONE!! - 'Reboot' or 'Logout' to apply changes"
fi
