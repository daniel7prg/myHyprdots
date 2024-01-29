#!/bin/bash

# Define the software that would be inbstalled 
#Need some prep work
prep_stage=(
    kitty
    pipewire
    wireplumber
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    polkit-gnome
    qt5-wayland
    qt5ct
    qt6-wayland
    qt6ct
    jq
    jaq
    gojq
    cliphist
)

#software for nvidia GPU only
nvidia_stage=(
    linux-headers 
    nvidia-dkms 
    nvidia-utils 
    libva 
    libva-nvidia-driver
)

#the main packages
install_stage=(
    kvantum
    gtk3
    nwg-look
    python
    python-pywal
    dunst
    eww-wayland
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
    firefox
    google-chrome
    pamixer
    pavucontrol
    brightnessctl
    bluez
    bluez-libs
    bluez-utils
    blueman
    playerctl
    gedit
    geticons
    papirus-icon-theme
    papirus-folders-catpuccin-git
    ttf-cascadia-code-nerd
    ttf-firacode-nerd
    ttf-jetbrains-mono-nerd
    sddm-git
)

backup_files=(
    dunst
    eww
    fish
    fontforge
    gedit
    gtk-3.0
    hypr
    kitty
    Kvantum
    menus
    neofetch
    nwg-look
    omf
    pulse
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
    echo -en "Done!\n"
    sleep 2
}

# function that will test for a package and if not found it will attempt to install it
install_software() {
    # First lets see if the package is there
    if yay -Q $1 &>> /dev/null ; then
        echo -e "$COK - $1 is already installed."
    else
        # no package found so installing
        echo -en "$CNT - Now installing $1 ."
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
    echo -en "$CNT - Configuering yay."
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

    # copy .config directory
    CONFDIR=~/.config
    if [ -d "$CONFDIR" ]; then
        echo -e "$COK - $CONFDIR found"
        wal -i .config/swww/wallpapers/MarioDev.gif.png
        cp -R .config $CONFDIR
    else
        echo -e "$CWR - $WLDIR NOT found, creating..."
        mkdir $CONFDIR
        wal -i .config/swww/wallpapers/MarioDev.gif.png
        cp -R .config $CONFDIR
    fi 

    # Setup each appliaction
    # check for existing config folders and backup 
    for DIR in ${backup_files[@]};
    do 
        DIRPATH=~/.config/$DIR
        if [ -d "$DIRPATH" ]; then 
            echo -e "$CAT - Config for $DIR located, backing up."
            mv $DIRPATH $DIRPATH-back &>> $INSTLOG
            echo -e "$COK - Backed up $DIR to $DIRPATH-back."
        fi

        # make new empty folders
        mkdir -p $DIRPATH &>> $INSTLOG
    done

    # link up the config files
    echo -e "$CNT - Setting up the new config..." 
    ln -sf ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc
    ln -sf ~/.cache/wal/Dracula-purple-solid.kvconfig ~/.config/Kvantum/Dracula-purple-solid/Dracula-purple-solid.kvconfig

    # add the Nvidia env file to the config (if needed)
    if [[ "$ISNVIDIA" == false ]]; then
        sed -i 's/env = LIBVA_DRIVER_NAME,nvidia/#env=LIBVA/' ~/.config/hypr/env.conf
        sed -i 's/env = WLR_NO_HARDWARE_CURSORS,1/#env=WLRCursors/' ~/.config/hypr/env.conf
    fi

    # Copy the SDDM theme
    echo -e "$CNT - Setting up the login screen."
    sudo cp -R sddm-theme/corners /usr/share/sddm/themes/
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
    sudo cp -R gtk-pywal/Decay-Green /usr/share/themes
    sudo cp -R gtk-pywal/Qogir-cursors /usr/share/icons
    sudo cp -R gtk-pywal/Qogir-whiet-cursors /usr/share/icons
    gsettings set org.gnome.desktop.interface gtk-theme Decay-Green
    gsettings set org.gnome.desktop.interface icon-theme Papirus
    gsettings set org.gnome.desktop.interface cursor-theme Qogir-cursors
    papirus-folders -C cat-mocha-blue
    echo "@import '${HOME}/.cache/wal/colors-waybar.css';" | cat - ~/gtk-dark.css > ~/gtk-dark2.css && sudo mv ~/gtk-dark2.css ~/gtk-dark.css
    sudo chown root:root /usr/share/themes/Decay-Green/gtk-3.0/gtk-dark.css
    chmod -R +x ~/.config/eww/scripts
    chmod -R +x ~/.config/hypr/scripts
    chmod -R +x ~/.config/rofi/scripts
    chmod -R +x ~/.config/swaylock/scripts
    chmod -R +x ~/.config/swww/scripts
    chmod -R +x ~/.config/wlogout/scripts
fi

### Install the fish shell ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like install the fish shell? (y,n) ' FISH
if [[ $FISH == "Y" || $FISH == "y" ]]; then
    # install the starship shell
    echo -e "$CAC - Installing fish..."
    sudo pacman -S --noconfirm fish
    echo -e "$COK - Complete!!"
    echo -e "$CNT - 1) You can install themes with omf into fish!!"
    echo -e "$CNT - 2) You can put fish shell using 'usermod -s' into the ${USER} or root!!"  
fi

read -rep $'[\e[1;33mACTION\e[0m] - Would you like install the zsh shell? (y,n) ' ZSH
if [[ $ZSH == "Y" || $ZSH == "y" ]]; then
    # install the starship shell
    echo -e "$CAC - Installing fish..."
    sudo pacman -S --noconfirm zsh zsh-syntax-highlighting zsh-autosuggestions
    echo -e "$COK - Complete!!"
    echo -e "$CNT - 1) You can install themes with omz & p10k into zsh!!"
    echo -e "$CNT - 2) You can put zsh shell using 'usermod -s' into the ${USER} or root!!"   
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