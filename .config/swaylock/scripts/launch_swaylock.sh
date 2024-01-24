#!/bin/bash

# WAYLAND_SESSION=wayland-1 swaylock ejecutar

# Import the colors
. "${HOME}/.cache/wal/colors.sh"

swaylock --ring-color "$color5" --inside-color "$background" --line-color "$background" \
--inside-ver-color="$background" --line-ver-color="$background" \
--inside-wrong-color="$background" --line-wrong-color="$background" \
--inside-clear-color="$background" --line-clear-color="$background" \
--key-hl-color "$foreground"

