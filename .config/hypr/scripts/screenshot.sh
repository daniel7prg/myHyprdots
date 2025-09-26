#!/bin/bash

#  ___________________
# | Simple Screenshot |
#  -------------------
temp_file=$(mktemp)
scr_dir=~/Screenshots
pkill -x slurp || grim -g "$(slurp)" - > $temp_file 

if [[ ! -d $scr_dir ]]; then mkdir -p $scr_dir; fi

if [[ -s "$temp_file" ]]; then
    file_name=$(date +'screenshot-%Y%m%d-%H%M.png')
    satty -f $temp_file -o "$scr_dir/$file_name"
    rm $temp_file
else
    exit 0
fi