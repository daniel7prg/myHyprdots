#!/bin/bash

#  _________________
# | Keyboard Layout |
#  -----------------

check_key(){
    # Get layout list - ouput on json format
    layout_list=$(cat ~/.config/hypr/conf/input.conf | grep 'kb_layout*' | cut -d '=' -f2 | sed 's/ //g')
    IFS=',' read -ra layout_array <<< "$layout_list"
    layout_count=${#layout_array[@]}

    if [[ -z "$layout_list" ]]; then
        sed -i 's/kb_layout = */kb_layout = us/g' ~/.config/hypr/conf/input.conf
        echo "Layout 󰌌 - Void a keyboard layout. Adding 'English' layout and exiting..."
        sleep 1
        exit 0
    elif [[ "$layout_count" -eq 1 ]]; then
        echo "Layout 󰌌 - Only one keyboard layout. Exiting..."
        sleep 1
        exit 0
    fi
}

current_key(){
    hyprctl -j devices | jq '.keyboards.[] | select(.main==true) | {device_name: .name, active_layout: .active_keymap, layouts: .layout}'
}

switch_key(){
    check_key
    echo "Switching layout..."
    hyprctl -q switchxkblayout current next
    sleep 1
    echo "Done!!"
}

help_view(){
cat << EOF

---Layouts on your keyboard---

hypr-keymap <action>
    -s --switch_kb    Switch keyboard
    -c --current_kb   Show info keyboard
    -h --help         Help view

Example:
    hypr-keymap -s    # Switch your keyboard layout
    hypr-keymap -c    # Show current keyboard device and layouts
EOF
}

case $1 in
    -s) switch_key ;;
    --switch_kb) switch_key ;;
    -c) current_key ;;
    --current_kb) current_key ;;
    -h) help_view ;;
    --help) help_view;;
    *) echo "Action not found | try '-h' or '--help'"
esac