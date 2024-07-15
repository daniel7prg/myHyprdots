#!/bin/bash

#  _________________
# | Keyboard Layout |
#  -----------------

keylay() {
    if [[ ${1:0:14} == "activelayout>>" ]]; then
        string=${1:14}
        title=${string/,/\ '\nLanguage (Layout): '}
        echo -e "Press 'Ctrl + C' for exit\n-----------------------------\nDevice (Keyboard): $title\n-----------------------------\n"
    fi
}

socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - |
while read -r line; do keylay "$line"; done