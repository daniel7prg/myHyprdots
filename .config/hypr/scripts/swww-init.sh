#!/bin/bash

#  _______________
# | Set wallpaper |
#  ---------------

## Default
WAL_DEF=~/wallpapers/default.png

#$ Set wallpaper
if [[ -d ~/.cache/swww ]]; then swww-daemon&
else
    swww-daemon&
    swww img $WAL_DEF
fi