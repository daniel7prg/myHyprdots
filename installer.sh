#!/bin/bash

# Define the software that would be inbstalled
# Original script by SolDoesTech (search github profile)
#Need some prep work
prep_stage=(
    pipewire
    wireplumber
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    polkit-gnome
    qt5-wayland
    qt5ct
    qt6-wayland
    qt6ct
    qt5-graphicaleffects
    qt5-svg
    qt5-quickcontrols2
    jq
    jaq
    gojq
    cliphist
    rustup
)

#software for nvidia GPU only
nvidia_stage=(
    linux-headers
    nvidia-dkms
    nvidia-utils
    libva
    libva-nvidia-drive
)

#the main packages
install_stage=(
    kvantum
    gtk3
    nwg-look
    python
    python-pywal
    dunst
    swww
    swaylock-effects
    rofi-lbonn-wayland-git
    wlogout
    swappy
    grim
    slurp
    thunar
    thunar-archive-plugin
    gvfs
    ntfs-3g
    file-roller
    pamixer
    pavucontrol
    brightnessctl
    bluez
    bluez-libs
    bluez-utils
    blueman
    playerctl
    gedit
    papirus-icon-theme
    papirus-folders-catppuccin-git
    ttf-cascadia-code-nerd
    ttf-firacode-nerd
    ttf-jetbrains-mono-nerd
    noto-fonts-emoji
    eww-wayland
    geticons
    sddm-git
)

backup_files=(
    dunst
    eww
    gedit
    gtk-3.0
    hypr
    Kvantum
    neofetch
    nwg-look
    qt5ct
    qt6ct
    rofi
    swappy
    swaylock
    swww
    wal
    wlogout
)

for str in ${myArray[@]}; do
  echo $str
done

# set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"
INSTLOG="install.log"

######
# functions go here

# function that would show a progress bar to the user
show_progress() {
    while ps | grep $1 &> /dev/null;
    do
        echo -n "#"
        sleep 2
    done
    echo -en " - Done!\n"
    sleep 2
}

# function that will test for a package and if not found it will attempt to install it
install_software() {
    # First lets see if the package is there
    if yay -Q $1 &>> /dev/null ; then
        echo -e "$COK - $1 is already installed."
    else
        # no package found so installing
        echo -en "$CNT - Now installing $1 #"
        yay -S --noconfirm $1 &>> $INSTLOG &
        show_progress $!
        # test to make sure package installed
        if yay -Q $1 &>> /dev/null ; then
            echo -e "\e[1A\e[K$COK - $1 was installed."
        else
            # if this is hit then a package is missing, exit to review log
            echo -e "\e[1A\e[K$CER - $1 install had failed, please check the install.log"
            exit
        fi
    fi
}

# clear the screen
clear

# set some expectations for the user
echo -e "-------------------------------------------"
echo -e "|   - ORIGINAL SCRIPT BY SOLDOESTECH -    |"
echo -e "-------------------------------------------"
echo -e "$CNT - You are about to execute a script that would attempt to setup Hyprland.
Please note that Hyprland is still in Beta."
sleep 1

# attempt to discover if this is a VM or not
echo -e "$CNT - Checking for Physical or VM..."
ISVM=$(hostnamectl | grep Chassis)
echo -e "Using $ISVM"
if [[ $ISVM == *"vm"* ]]; then
    echo -e "$CWR - Please note that VMs are not fully supported and if you try to run this on
    a Virtual Machine there is a high chance this will fail."
    sleep 1
fi

# let the user know that we will use sudo
echo -e "$CNT - This script will run some commands that require sudo. You will be prompted to enter your password.
If you are worried about entering your password then you may want to review the content of the script."
sleep 1

# give the user an option to exit out
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to continue with the install (y,n) ' CONTINST
if [[ $CONTINST == "Y" || $CONTINST == "y" ]]; then
    echo -e "$CNT - Setup starting..."
    sudo touch /tmp/hyprv.tmp
else
    echo -e "$CNT - This script will now exit, no changes were made to your system."
    exit
fi

# find the Nvidia GPU
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    ISNVIDIA=true
else
    ISNVIDIA=false
fi

### Disable wifi powersave mode ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to disable WiFi powersave? (y,n) ' WIFI
if [[ $WIFI == "Y" || $WIFI == "y" ]]; then
    LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
    echo -e "$CNT - The following file has been created $LOC.\n"
    echo -e "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC &>> $INSTLOG
    echo -en "$CNT - Restarting NetworkManager service, Please wait."
    sleep 2
    sudo systemctl restart NetworkManager &>> $INSTLOG
    
    #wait for services to restore (looking at you DNS)
    for i in {1..6} 
    do
        echo -n "."
        sleep 1
    done
    echo -en "Done!\n"
    sleep 2
    echo -e "\e[1A\e[K$COK - NetworkManager restart completed."
fi

#### Check for package manager ####
if [ ! -f /sbin/yay ]; then  
    echo -en "$CNT - Configuering yay "
    git clone https://aur.archlinux.org/yay.git &>> $INSTLOG
    cd yay
    makepkg -si --noconfirm &>> ../$INSTLOG &
    show_progress $!
    if [ -f /sbin/yay ]; then
        echo -e "\e[1A\e[K$COK - yay configured"
        cd ..
        
        # update the yay database
        echo -en "$CNT - Updating yay."
        yay -Suy --noconfirm &>> $INSTLOG &
        show_progress $!
        echo -e "\e[1A\e[K$COK - yay updated."
    else
        # if this is hit then a package is missing, exit to review log
        echo -e "\e[1A\e[K$CER - yay install failed, please check the install.log"
        exit
    fi
fi



### Install all of the above pacakges ####
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install the packages? (y,n) ' INST
if [[ $INST == "Y" || $INST == "y" ]]; then

    # Prep Stage - Bunch of needed items
    echo -e "$CNT - Prep Stage - Installing needed components, this may take a while..."
    for SOFTWR in ${prep_stage[@]}; do
        install_software $SOFTWR 
    done

    # Setup Nvidia if it was found
    if [[ "$ISNVIDIA" == true ]]; then
        echo -e "$CNT - Nvidia GPU support setup stage, this may take a while..."
        for SOFTWR in ${nvidia_stage[@]}; do
            install_software $SOFTWR
        done
    
        # update config
        sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        sudo mkinitcpio -P
        
        if [[ -z "$(yay -Ss grub)" ]]; then
            echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf &>> $INSTLOG
        else
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 nvidia_drm.modeset=1"/' /etc/default/grub
        fi
    fi

    # Install the correct hyprland version
    echo -e "$CNT - Installing Hyprland, this may take a while..."   
    install_software hyprland

    # Config rustup
    sleep 1
    rustup default stable

    # Stage 1 - main components
    echo -e "$CNT - Installing main components, this may take a while..."
    for SOFTWR in ${install_stage[@]}; do
        install_software $SOFTWR 
    done

    # Start the bluetooth service
    echo -e "$CNT - Starting the Bluetooth Service..."
    sudo systemctl enable --now bluetooth.service &>> $INSTLOG
    sleep 2

    # Enable the sddm login manager service
    echo -e "$CNT - Enabling the SDDM Service..."
    sudo systemctl enable sddm &>> $INSTLOG
    sleep 2
    
    # Clean out other portals
    echo -e "$CNT - Cleaning out conflicting xdg portals..."
    yay -R --noconfirm xdg-desktop-portal-gnome &>> $INSTLOG

fi

### Copy Config Files ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to copy config files? (y,n) ' CFG
if [[ $CFG == "Y" || $CFG == "y" ]]; then
    echo -e "$CNT - Copying config files..."

    # check for existing config folders and backup 
    # for DIR in ${backup_files[@]};
    # do 
    #    DIRPATH=~/.config/$DIR
    #    if [ -d "$DIRPATH" ]; then 
    #        echo -e "$CAT - Config for $DIR located, backing up."
    #        mv $DIRPATH $DIRPATH-back &>> $INSTLOG
    #        echo -e "$COK - Backed up $DIR to $DIRPATH-back."
    #    fi
    # done

    # copy .config directory
    CONFDIR=~/.config
    if [ -d "$CONFDIR" ]; then
        echo -e "$COK - $CONFDIR found"
    else
        echo -e "$CWR - $CONFDIR NOT found, creating..."
        mkdir $CONFDIR
    fi
    
    wal -q -i .config/swww/wallpapers/MarioDev.gif.png
    cp -R .config/ ~/
    wal -q -i .config/swww/wallpapers/MarioDev.gif.png
    # link up the config files
    echo -e "$CNT - Setting up the new config..."

    # add the Nvidia env file to the config (if needed)
    if [[ "$ISNVIDIA" == false ]]; then
        sed -i 's/env = LIBVA_DRIVER_NAME,nvidia/#env=LIBVA/' ~/.config/hypr/env.conf
    fi

    # Copy the SDDM theme
    echo -e "$CNT - Setting up the login screen."
    sudo cp -R sddm-theme/corners/ /usr/share/sddm/themes/corners/
    mv sddm-theme/user.face.icon sddm-theme/$USER.face.icon
    sudo cp sddm-theme/$USER.face.icon /usr/share/sddm/faces/
    sudo cp sddm-theme/sddm.conf /etc/
    WLDIR=/usr/share/wayland-sessions
    if [ -d "$WLDIR" ]; then
        echo -e "$COK - $WLDIR found"
    else
        echo -e "$CWR - $WLDIR NOT found, creating..."
        sudo mkdir $WLDIR
    fi 
    
    # stage the .desktop file
    sudo cp hyprland.desktop /usr/share/wayland-sessions/

    # setup the first look and feel as dark
    sudo cp -R gtk-pywal/Decay-Green/ /usr/share/themes/Decay-Green/
    sudo cp -R gtk-pywal/Qogir-cursors/ /usr/share/icons/Qogir-cursors/
    sudo cp -R gtk-pywal/Qogir-white-cursors/ /usr/share/icons/Qogir-white-cursors/
    gsettings set org.gnome.desktop.interface gtk-theme Decay-Green
    gsettings set org.gnome.desktop.interface icon-theme Papirus
    gsettings set org.gnome.desktop.interface cursor-theme Qogir-cursors
    #kvantum bug
    #kvantummanager --set Dracula-purple-solid
    #kvantummanager --assign Dracula-purple-solid qt5ct qt6ct
    ln -sf ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc
    ln -sf ~/.cache/wal/Dracula-purple-solid.kvconfig ~/.config/Kvantum/Dracula-purple-solid/Dracula-purple-solid.kvconfig
    papirus-folders -C cat-mocha-blue
    sudo sed -i "2i @import '${HOME}/.cache/wal/colors-waybar.css';" /usr/share/themes/Decay-Green/gtk-3.0/gtk-dark.css
    echo "@import '${HOME}/.cache/wal/colors-waybar.css';" > ~/.config/eww/scss/colors.scss
    sudo chown root:root /usr/share/themes/Decay-Green/gtk-3.0/gtk-dark.css
    chmod -R +x ~/.config/eww/scripts/
    chmod -R +x ~/.config/hypr/scripts/
    chmod -R +x ~/.config/rofi/scripts/
    chmod -R +x ~/.config/swaylock/scripts/
    chmod -R +x ~/.config/swww/scripts/
    chmod -R +x ~/.config/wlogout/scripts/
fi

### Install the fish shell ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like install any these fish(f)/zsh(z) shells? (f,z,n) ' FIZSH
if [[ $FIZSH == "F" || $FIZSH == "f" ]]; then
    # install the fish shell
    echo -e "$CAC - Installing fish..."
    sudo pacman -Sq --noconfirm fish lsd bat &>> $INSTLOG
    echo -e "$COK - Done!!"
    echo -e "$CAC - Set fish by default..."
    sleep 1
    sudo usermod -s /usr/bin/fish $USER
    echo -e "$COK - Done!!"
elif [[ $FIZSH == "Z" || $FIZSH == "z" ]]; then
    # install the zsh shell
    echo -e "$CAC - Installing zsh..."
    sudo pacman -Sq --noconfirm zsh zsh-syntax-highlighting zsh-autosuggestions lsd bat &>> $INSTLOG
    echo -e "$COK - Done!!"
    echo -e "$CAC - Set zsh by default..."
    sleep 1
    echo "#Create .zshrc file" > ~/.zshrc
    sudo usermod -s /usr/bin/zsh $USER
    echo -e "$COK - Done!!"
fi

# Install themes shells
read -rep $'[\e[1;33mACTION\e[0m] - Would you like install theme to shell? (y,n) ' THEME
if [[ $THEME == "Y" || $THEME == "y" ]]; then
    if [[ -e ~/.zshrc ]]; then
        # install theme zsh
        echo "----------------------------------"
        echo -e "$CNT Installing theme for zsh"
        echo "----------------------------------"
        read -rep $'[\e[1;33mACTION\e[0m] - Would you like install oh-my-zsh(o)/starship(s)? (o,s,n) ' TZSH
        if [[ $TZSH == "O" || $TZSH == "o" ]]; then
            echo -e "$CAC - Installing om-my-zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            sed -i '76isource /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' ~/.zshrc
            sed -i '77isource /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' ~/.zshrc
            echo -e "\n" >> ~/.zshrc
            echo -e '#Alias\nalias cat="bat"\nalias ls="lsd"' >> ~/.zshrc
            echo -e "$CNT - You can customize theme with p10k"
            echo -e "$CNT - See more searching power-level-10k on web"
            echo -e "$COK - Done!!"
        elif [[ $TZSH == "S" || $TZSH == "s" ]]; then
            echo -e "$CAC - Installing starship..."
            sudo pacman -Sq --noconfirm starship
            echo -e 'eval "$(starship init zsh)"\n' >> ~/.zshrc
            echo -e "#Plugins\nsource /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
            echo -e "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh\n" >> ~/.zshrc
            echo -e '#Alias\nalias cat="bat"\nalias ls="lsd"' >> ~/.zshrc
            echo -e "$CNT - You can change theme with presets"
            echo -e "$CNT - See more searching starship presets on web"
            echo -e "$COK - Done!!"
        fi
    fi
    if [[ -e ~/.config/fish/config.fish ]]; then
        # install theme fish
        echo "----------------------------------"
        echo -e "$CNT Installing theme for fish"
        echo "----------------------------------"
        read -rep $'[\e[1;33mACTION\e[0m] - Would you like install oh-my-fish(o)/starship(s)? (o,s,n) ' TFSH
        if [[ $TFSH == "O" || $TFSH == "o" ]]; then
            echo -e "$CAC - Installing om-my-fish..."
            curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install
            fish install --path=~/.local/share/omf --config=~/.config/omf --noninteractive --yes
            cp shells/fish/config.fish ~/.config/fish/
            echo -e "$CNT - You can change theme with command omf"
            echo -e "$CNT - See more searching oh-my-fish on web"
            echo -e "$COK - Done!!"
        elif [[ $TFSH == "S" || $TFSH == "s" ]]; then
            echo -e "$CAC - Installing starship..."
            sudo pacman -Sq --noconfirm starship
            cp shells/fish/configS.fish ~/.config/fish/
            rm ~/.config/fish/config.fish
            mv ~/.config/fish/configS.fish ~/.config/fish/config.fish
            echo -e "$CNT - You can change theme with presets"
            echo -e "$CNT - See more searching starship presets on web"
            echo -e "$COK - Done!!"
        fi
    fi
    if [[ -e ~/.bashrc ]]; then
        # Install theme bash
        echo "----------------------------------"
        echo -e "$CNT Installing theme for bash"
        echo "----------------------------------"
        read -rep $'[\e[1;33mACTION\e[0m] - Would you like install oh-my-posh(o)/starship(s)? (o,s,n) ' TBSH
        if [[ $TBSH == "O" || $TBSH == "o" ]]; then
            echo -e "$CAC - Installing om-my-posh..."
            mkdir ~/.oh-my-posh
            curl -s https://ohmyposh.dev/install.sh | bash -s
            sed -i '7ieval "$(oh-my-posh init bash --config ~/.cache/oh-my-posh/themes/amro.omp.json)"' ~/.bashrc
            sed -i '10ialias cat="bat"' ~/.bashrc
            sed -i "s/alias ls='ls --color=auto'/alias ls='lsd'/" ~/.bashrc
            echo -e "$CNT - You can customize theme"
            echo -e "$CNT - See more searching oh-my-posh (bash) on web"
            echo -e "$COK - Done!!"
        elif [[ $TBSH == "S" || $TBSH == "s" ]]; then
            echo -e "$CAC - Installing starship..."
            sudo pacman -Sq --noconfirm starship
            cp shells/bash/.bashrc ~/
            echo -e "$CNT - You can change theme with presets"
            echo -e "$CNT - See more searching starship presets on web"
            echo -e "$COK - Done!!"
        fi
    fi
fi

### Install termial kitty/foot
if [[ $ISVM == *"vm"* ]]; then
    echo -e "$CNT - Please note that VMs are not fully supported kitty, I recommend installing foot instead"
    sed -i 's/blurls=gtk-layer-shell/#blurls=gtk-layer-shell/' ~/.config/hypr/hyprland.conf
    sed -i 's/layerrule=ignorezero,gtk-layer-shell/#layerrule=ignorezero,gtk-layer-shell/' ~/.config/hypr/hyprland.conf
    sleep 1
fi

read -rep $'[\e[1;33mACTION\e[0m] - Would you like install any these kitty(k)/foot(f) terminals? (k,f,n) ' TERM
if [[ $TERM == "K" || $TERM == "k" ]]; then
    # install kitty
    echo -e "$CAC - Installing kitty..."
    sudo pacman -Sq --noconfirm kitty &>> $INSTLOG
    
    if [[ -e ~/.zshrc ]]; then
        echo 'alias icat="kitten icat"' >> ~/.zshrc
    elif [[ -e ~/.config/fish/config.fish ]]; then
        sed -i '3ialias icat="kitten icat"' ~/.config/fish/config.fish
    else
        echo 'alias icat="kitten icat"' >> ~/.bashrc
    fi

    echo -e "$COK - Done!!"
elif [[ $TERM == "F" || $TERM == "f" ]]; then
    # install foot
    echo -e "$CAC - Installing foot..."
    rm -R ~/.config/kitty/
    sudo pacman -Sq --noconfirm foot &>> $INSTLOG
    mkdir -p ~/.config/foot
    cp shells/bash/foot.ini ~/.config/wal/templates/
    wal -q -i .config/swww/wallpapers/MarioDev.gif.png
    cp ~/.cache/wal/foot.ini ~/.config/foot/
    sed -i 's/#/ /g' ~/.config/foot/foot.ini
    sed -i 's/image_backend=kitty/image_backend=ascii/' ~/.config/neofetch/config.conf
    sed -i 's/bind = $mainMod, Q, exec, kitty/bind = $mainMod, Q, exec, foot/' ~/.config/hypr/hyprland.conf
    echo -e "$COK - Done!!"
fi

## Install browser

read -rep $'[\e[1;33mACTION\e[0m] - Would you like install any these Firefox(f)/Chrome(g)/Chromium(c)/Brave(b) browsers? (f,g,c,b,n) ' BROWSER
if [[ $BROWSER == "F" || $BROWSER == "f" ]]; then
    # install firefox
    echo -e "$CAC - Installing Firefox..."
    sudo pacman -Sq --noconfirm firefox &>> $INSTLOG
    echo -e "$COK - Done!!"
    echo -e "$CNT - Remember to set the theme to gtk"
elif [[ $BROWSER == "G" || $BROWSER == "g" ]]; then
    # install Chrome
    echo -e "$CAC - Installing Chrome..."
    yay -Sq --noconfirm google-chrome &>> $INSTLOG
    echo -e "$COK - Done!!"
    echo -e "$CNT - 1) Remember to set the theme to gtk"
    echo -e "$CNT - 2) Remember to enable 'Preferred Ozone platform=Wayland' flag in 'chrome://flags/'"
elif [[ $BROWSER == "C" || $BROWSER == "C" ]]; then
    # install Chromium
    echo -e "$CAC - Installing Chromium..."
    sudo pacman -Sq --noconfirm chromium &>> $INSTLOG
    echo -e "$COK - Done!!"
    echo -e "$CNT - 1) Remember to set the theme to gtk"
    echo -e "$CNT - 2) Remember to enable 'Preferred Ozone platform=Wayland' flag in 'chrome://flags/'"
elif [[ $BROWSER == "B" || $BROWSER == "b" ]]; then
    # install Brave
    echo -e "$CAC - Installing Brave..."
    yay -Sq --noconfirm brave-bin &>> $INSTLOG
    echo -e "$COK - Done!!"
    echo -e "$CNT - 1) Remember to set the theme to gtk"
    echo -e "$CNT - 2) Remember to enable 'Preferred Ozone platform=Wayland' flag in 'brave://flags/'"
fi

### Script is done ###
echo -e "$CNT - Script had completed!"
if [[ "$ISNVIDIA" == true ]]; then 
    echo -e "$CAT - Since we attempted to setup an Nvidia GPU the script will now end and you should reboot.
    Please type 'reboot' at the prompt and hit Enter when ready."
    exit
fi

read -rep $'[\e[1;33mACTION\e[0m] - Would you like to start Hyprland now? (y,n) ' HYP
if [[ $HYP == "Y" || $HYP == "y" ]]; then
    exec sudo systemctl start sddm &>> $INSTLOG
else
    exit
fi