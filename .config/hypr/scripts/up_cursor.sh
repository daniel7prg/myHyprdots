#!/bin/bash

#  _____________________
# | Update cursor theme |
#  ---------------------

THEME_CURSOR=$(gsettings get org.gnome.desktop.interface cursor-theme | sed "s/'//g")
SIZE_CURSOR=$(gsettings get org.gnome.desktop.interface cursor-size)

sudo sed -i "s/Inherits=.*/Inherits=$THEME_CURSOR/" /usr/share/icons/default/index.theme
sudo sed -i "s/CursorSize=.*/CursorSize=$SIZE_CURSOR/" /etc/sddm.conf
sed -i "s/env = XCURSOR_SIZE,.*/env = XCURSOR_SIZE,$SIZE_CURSOR/" ~/.config/hypr/conf/env.conf
sed -i "s/env = HYPRCURSOR_SIZE,.*/env = HYPRCURSOR_SIZE,$SIZE_CURSOR/" ~/.config/hypr/conf/env.conf
#hyprctl setcursor $THEME_CURSOR $SIZE_CURSOR
echo "DONE!! - 'Reboot' or 'Exit' Hyprland Session to apply changes"
