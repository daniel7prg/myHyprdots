#!/bin/bash

#  ________________
# | Volume Control |
#  ----------------

# Current icon theme
icontheme=$(grep -o "gtk-icon-theme-name.*" ~/.config/gtk-3.0/settings.ini | cut -d "=" -f 2)

#Vol vars
icon_vol="volume-level"
icon_vol_lvl="high"
icon_vol_state="muted"
sink_vol=$(pactl list sinks | grep -oP '(?<=Active Port: ).*')

#Mic vars
icon_mic="microphone-sensitivity"
icon_mic_state="muted"

# Search icon
iconpath=$(geticons "${icon_vol}-${icon_vol_lvl}" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)
    
if [[ -z "$iconpath" ]]; then
    icon_vol="audio-volume"
fi

notify_vol (){
    vol_level=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}'| sed 's/%//')

    # Vol icons
    if [[ "$sink_vol" == "analog-output-headphones" ]]; then 
        iconpath_vol=$(geticons "audio-headphones" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)
    else
        if [[ $vol_level -gt 60 ]]; then
            icon_vol_lvl="high"
            iconpath_vol=$(geticons "${icon_vol}-${icon_vol_lvl}" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)
        elif [[ $vol_level -gt 40 ]]; then
            icon_vol_lvl="medium"
            iconpath_vol=$(geticons "${icon_vol}-${icon_vol_lvl}" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)
        elif [[ $vol_level -ge 0 ]]; then
            icon_vol_lvl="low"
            iconpath_vol=$(geticons "${icon_vol}-${icon_vol_lvl}" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)
        fi
    fi
    dunstify "t2" -a "Vol: ${vol_level}%" -h int:value:$vol_level -i $iconpath_vol -r 91190 -t 800 
}

notify_mute_vol (){
    status_vol=$(pactl get-sink-mute @DEFAULT_SINK@ toggle | awk '{print $2}')

    # Mute vol
    if [[ "$status_vol" == "yes" ]]; then
        iconpath_vol_mtd=$(geticons "${icon_vol}-${icon_vol_state}" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)
        dunstify "t2" -a "Muted" "<big>Volume</big>" -i $iconpath_vol_mtd -r 91190 -t 800 
    elif [[ "$status_vol" == "no" ]]; then
        icon_vol_state="high"
        iconpath_vol_mtd=$(geticons "${icon_vol}-${icon_vol_state}" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)
        echo $iconpath_vol_mtd
        dunstify "t2" -a "Unmuted" "<big>Volume</big>" -i $iconpath_vol_mtd -r 91190 -t 800 
    fi
}

notify_mute_mic (){
    status_mic=$(pactl get-source-mute @DEFAULT_SOURCE@ toggle | awk '{print $2}')

    # Mute mic
    if [[ "$status_mic" == "yes" ]]; then
        iconpath_mic_mtd=$(geticons "${icon_mic}-${icon_mic_state}" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)
        dunstify "t2" -a "MuteD" "<big>Microphone</big>" -i $iconpath_mic_mtd -r 91190 -t 800 
    elif [[ "$status_mic" == "no" ]]; then
        icon_mic_state="high"
        iconpath_mic_mtd=$(geticons "${icon_mic}-${icon_mic_state}" -s 16 -c 1 -t "$icontheme" --no-fallbacks | head -n 1)
        dunstify "t2" -a "Unmuted" "<big>Microphone</big>" -i $iconpath_mic_mtd -r 91190 -t 800 
    fi
}

case $1 in
    -a) pactl set-sink-mute @DEFAULT_SINK@ toggle
        notify_mute_vol ;;
    -m) pactl set-source-mute @DEFAULT_SOURCE@ toggle
        notify_mute_mic ;;
    -i) vol_state=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}'| sed 's/%//')
        if [[ $vol_state -le 95 ]]; then
            pactl set-sink-volume @DEFAULT_SINK@ +5%
        fi
        notify_vol ;;
	-d) pactl set-sink-volume @DEFAULT_SINK@ -5%
        notify_vol ;;
esac