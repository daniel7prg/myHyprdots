alias cat="bat"
alias ls="lsd"


function fish_greeting
    echo Hello $USER!
    echo The time is (set_color yellow; date +%T; set_color normal)
end