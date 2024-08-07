#
# ~/.bashrrc
#
function blastoff(){
    echo " 󰣇 "
}

# Trap DEBUG *before* running starship
trap blastoff DEBUG     
set -o functrace
eval $(starship init bash)
set +o functrace

alias cat="bat"
alias ls="lsd"
alias grep="grep --color=auto"
alias update-cursor="~/.config/hypr/scripts/up_cursor.sh"
alias hypr-keymap="~/.config/hypr/scripts/hypr-keymap.sh"