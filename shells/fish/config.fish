alias cat="bat"
alias ls="lsd"
alias update-cursor="~/.config/hypr/scripts/up_cursor.sh"


function fish_greeting
    echo Hello $USER!
    echo The time is (set_color yellow; date +%T; set_color normal)
end