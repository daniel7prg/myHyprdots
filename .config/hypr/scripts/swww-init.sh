#!/bin/bash

#  _______________
# | Set wallpaper |
#  ---------------

## Default
WAL_DEF=~/wallpapers/waiting.jpeg

## Set wallpaper
if [[ -d ~/.cache/swww ]]; then 
    swww-daemon&
else
    swww-daemon&
    SEARCH=($(grep -l -w "connected" /sys/class/drm/card0/card0-*/status))

    for ruta in "${SEARCH[@]}"; do
        ACTIVE=`basename $(dirname "$ruta")`
        CURRENT=($ACTIVE)
        MONITOR=($(echo "${CURRENT[@]}" | grep -oP "(?<=card0-).*"))
        swww img -o "${MONITOR[@]}" $WAL_DEF
    done
    sleep 5s
    matugen -q -m dark image ${WAL_DEF}
fi