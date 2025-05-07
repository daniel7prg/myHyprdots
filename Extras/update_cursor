#!/bin/bash

#  _____________________
# | Update cursor theme |
#  ---------------------

update_cursor(){
    THEME_CURSOR=$(gsettings get org.gnome.desktop.interface cursor-theme | sed "s/'//g")
    SIZE_CURSOR=$(gsettings get org.gnome.desktop.interface cursor-size)

    echo "Configuring cursor to Hyprland "
    sleep 1
    sudo sed -i "s/Inherits=.*/Inherits=$THEME_CURSOR/" /usr/share/icons/default/index.theme
    echo "Configuring cursor to Display Manager 󰗽"
    sleep 1
    sudo sed -i "s/CursorSize=.*/CursorSize=$SIZE_CURSOR/" /etc/sddm.conf
    sed -i -e "s/env = XCURSOR_SIZE,.*/env = XCURSOR_SIZE,$SIZE_CURSOR/" -e "s/env = HYPRCURSOR_SIZE,.*/env = HYPRCURSOR_SIZE,$SIZE_CURSOR/" ~/.config/hypr/conf/env.conf
    echo " DONE!! - 'Reboot' or 'Logout' to apply changes"
}

help_view(){
cat << EOF

---Update Cursor Theme---

up_cursor <action>
    -s --set          Cursor theme
    -h --help         Help view

Example:
    hypr-keymap -s    # Set current cursor theme
    hypr-keymap -h    # Show this message
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    help_view
elif [[ "$1" == "-s" || "$1" == "--set" ]]; then
    update_cursor
else
    echo "Action not found | try '-h' or '--help'"
fi