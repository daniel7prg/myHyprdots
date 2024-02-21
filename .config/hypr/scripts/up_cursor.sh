#!/bin/bash

#  _____________________
# | Update cursor theme |
#  ---------------------

THEME_CURSOR=$(gsettings get org.gnome.desktop.interface cursor-theme | sed "s/'//g")
SIZE_CURSOR=$(gsettings get org.gnome.desktop.interface cursor-size)

sudo sed -i "s/Inherits=.*/Inherits=$THEME_CURSOR/" /usr/share/icons/default/index.theme
sed -i "s/env = XCURSOR_SIZE,.*/env = XCURSOR_SIZE,$SIZE_CURSOR/" ~/.config/hypr/conf/env.conf
hyprctl setcursor $THEME_CURSOR $SIZE_CURSOR

