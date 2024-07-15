alias cat="bat"
alias ls="lsd"
alias update-cursor="~/.config/hypr/scripts/up_cursor.sh"
alias hypr-keymap="~/.config/hypr/scripts/hypr-keymap.sh"


function fish_greeting
    echo Hello $USER!
    echo The time is (set_color yellow; date +%T; set_color normal)
end

function starship_transient_prompt_func
    starship module character
end

starship init fish | source
enable_transience