#!/bin/bash

#  ___________________
# | Simple Screenshot |
#  -------------------
temp_file=$(mktemp)
pkill -x slurp || grim -g "$(slurp)" - > $temp_file 
file_name=$(date +'screenshot-%Y%m%d-%H%M.png')
swappy -f $temp_file -o "$file_name"
rm $temp_file
rm $file_name

if [[ -e ~/Imagenes/${file_name} ]]; then
    notify-send -a "Swappy" "Screenshot" "Saved in $HOME/Imagenes/${file_name}" -i ~/Imagenes/${file_name} -r 91190 -t 8000
fi