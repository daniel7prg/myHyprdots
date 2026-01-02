#!/bin/bash

# Define the software that would be inbstalled
# Original script by SolDoesTech (search github profile)
# Need some prep work
prep_stage=(
    pipewire
    wireplumber
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    pantheon-polkit-agent
    qt5-wayland
    qt5ct
    qt6-wayland
    qt6ct
    qt5-graphicaleffects
    qt5-svg
    qt5-quickcontrols2
    jq
    jaq
    cliphist
    rustup
    usleep
    yad
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
    eww
    kvantum
    kvantum-qt5
    bluez
    bluez-utils
    matugen
    dunst
    swww
    hyprlock
    rofi-wayland
    firefox
    satty
    grim
    slurp
    thunar
    thunar-archive-plugin
    gvfs
    ntfs-3g
    file-roller
    pavucontrol
    brightnessctl
    blueman
    playerctl
    gedit
    papirus-icon-theme
    ttf-cascadia-code-nerd
    ttf-firacode-nerd
    ttf-jetbrains-mono-nerd
    ttf-noto-nerd
    ttf-google-sans
    noto-fonts-emoji
    geticons-git
    power-profiles-daemon
    nwg-clipman
    fastfetch
)

backup_files=(
    kitty
    foot
    fish
    omf
    dunst
    eww
    gtk-3.0
    gtk-4.0
    hypr
    Kvantum
    fastfetch
    qt5ct
    qt6ct
    rofi
    satty
    swww
    matugen
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
echo -e "-------------------------------------------\n"
echo -e "$CNT - You are about to execute a script that would attempt to setup Hyprland.
Please note that Hyprland is still in Beta."
sleep 1

# attempt to discover if this is a VM or not
echo -e "$CNT - Checking for Physical or VM..."
ISVM=$(hostnamectl | grep Chassis)
echo -e "Using $ISVM"
if [[ $ISVM == *"vm"* ]]; then
    echo -e "$CWR - Please note that VMs are not fully supported and if you try to run this on
    a Virtual Machine there is a high chance this will fail.\nSome dependencies will be installed."
    echo -e "$CWR - Install any necessary dependencies according to your virtualization software, be it VM Ware, VirtualBox or any other."
    sleep 2
fi

# let the user know that we will use sudo
echo -e "$CNT - This script will run some commands that require sudo. You will be prompted to enter your password.
If you are worried about entering your password then you may want to review the content of the script."
sleep 1

# give the user an option to exit out
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to continue with the install (y,n): ' CONTINST
if [[ $CONTINST == "Y" || $CONTINST == "y" ]]; then
    echo -e "$CNT - Setup starting..."
    echo -e "$CAT - Please type your sudo password..."
    sudo echo -e "$CNT - Checking..."
    sleep 2s
    echo -e "$COK - Correct! Installing..."
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
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to disable WiFi powersave? (y,n): ' WIFI
if [[ $WIFI == "Y" || $WIFI == "y" ]]; then
    LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
    echo -e "$CNT - The following file has been created $LOC.\n"
    echo -e "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC &>> $INSTLOG
    echo -en "$CNT - Restarting NetworkManager service, Please wait."
    sleep 2
    sudo systemctl restart NetworkManager &>> $INSTLOG
    
    #wait for services to restore (looking at you DNS)
    for i in {1..6}; do
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

### Install all of the above packages ####
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install the packages? (y,n): ' INST
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
        
        if [[ -z "$(pacman -Q grub)" ]]; then
            echo -e "$CWR - If you use systemd-boot or some other bootloader then refer to the Hyprland wiki (Nvidia Section) for more information"
        else
            sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=s/"$/ nvidia_drm.modeset=1"/' /etc/default/grub &>> $INSTLOG
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

fi

### Copy Config Files ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to copy config files? (y,n): ' CFG
if [[ $CFG == "Y" || $CFG == "y" ]]; then
    echo -e "$CNT - Copying config files..."

    # check for existing config folders and backup 
    CONFDIR=~/.config
    if [ -d "$CONFDIR" ]; then
        echo -e "$COK - $CONFDIR found"
        read -rep $'[\e[1;33mACTION\e[0m] - Would you like to make a copy of your files? (y,n): ' BFG
        if [[ $BFG == "Y" || $BFG == "y" ]]; then
            for DIR in ${backup_files[@]}; do 
                DIRPATH=~/.config/$DIR
                if [ -d "$DIRPATH" ]; then 
                    echo -e "$CAT - Config for $DIR located, backing up."
                    mv $DIRPATH $DIRPATH-back &>> $INSTLOG
                    echo -e "$COK - Backed up $DIR to $DIRPATH-back."
                fi
            done
            cp -R .config/ ~/
        else
            cp -R .config/ ~/
        fi
    else
        echo -e "$CWR - $CONFDIR NOT found, creating..."
        # copy .config directory
        mkdir $CONFDIR
        cp -R .config/ ~/
    fi
    
    # setting config files
    echo -e "$CNT - Setting up the new config..."

    # add the Nvidia env file to the config (if needed)
    if [[ "$ISNVIDIA" == false ]]; then
        sed -i 's/env = LIBVA_DRIVER_NAME,nvidia/#env=LIBVA/' ~/.config/hypr/conf/env.conf
    fi

    # Copy the Hyprland session
    WLDIR=/usr/share/wayland-sessions
    if [ -d "$WLDIR" ]; then
        echo -e "$COK - $WLDIR found"
    else
        echo -e "$CWR - $WLDIR NOT found, creating..."
        sudo mkdir $WLDIR
    fi 
    
    # stage the .desktop file
    sudo cp Extras/hyprland.desktop /usr/share/wayland-sessions/

    # copy custom commands
    CMDDIR=~/.local/bin
    if [ -d "$CMDDIR" ]; then
        echo -e "$COK - $CMDDIR found"
    else
        echo -e "$CWR - $CMDDIR NOT found, creating..."
        sudo mkdir $CMDDIR
    fi

    # Verify colorscheme directory
    CLRDIR=~/.local/share/color-schemes
    if [ -d "$CLRDIR" ]; then
        echo -e "$COK - $CLRDIR found"
    else
        echo -e "$CWR - $CLRDIR NOT found, creating..."
        sudo mkdir $CLRDIR
    fi

    # new command tools
    sudo cp Extras/hypr_keymap ~/.local/bin/
    sudo cp Extras/update_cursor ~/.local/bin/

    # setup the first look and feel as dark
    sudo cp -R Extras/Material-U/ /usr/share/themes/Material-U/
    sudo cp -R Extras/Qogir-cursors/ /usr/share/icons/Qogir-cursors/
    sudo cp -R Extras/Qogir-white-cursors/ /usr/share/icons/Qogir-white-cursors/
    sed -i "s|color_scheme_path=.*|color_scheme_path=${HOME}/.config/qt5ct/colors/matugen.conf|" ~/.config/qt5ct/qt5ct.conf
    sed -i "s|color_scheme_path=.*|color_scheme_path=${HOME}/.config/qt6ct/colors/matugen.conf|" ~/.config/qt6ct/qt6ct.conf
    gsettings set org.gnome.desktop.interface gtk-theme Material-U
    gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
    gsettings set org.gnome.desktop.interface cursor-theme Qogir-cursors
    gsettings set org.gnome.desktop.interface font-name 'JetBrainsMonoNL Nerd Font Propo Semi-Bold 13'
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    sudo sed -i "2i @import '${HOME}/.cache/wal/colors-gtk.css';" /usr/share/themes/Material-U/gtk-3.0/gtk-dark.css
    sudo sed -i "2i @import '${HOME}/.cache/wal/colors-gtk.css';" /usr/share/themes/Material-U/gtk-4.0/gtk-dark.css
    sudo sed -i 's/Inherits=Adwaita/Inherits=Qogir-cursors/' /usr/share/icons/default/index.theme
fi

### Install SDDM
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install Display Manager (SDDM)? (y,n): ' SDDM
if [[ $SDDM == "Y" || $SDDM == "y" ]]; then
    echo -e "$CAC - Installing componenets..."
    install_software sddm
    echo -e "$CAC - Setting up componenets..."
    echo -e "$CNT - Setting up the login screen."
    sudo cp -R sddm-theme/corners/ /usr/share/sddm/themes/corners/
    mv sddm-theme/user.face.icon sddm-theme/$USER.face.icon
    sudo cp sddm-theme/$USER.face.icon /usr/share/sddm/faces/
    sudo cp sddm-theme/sddm.conf /etc/
    echo -e "$CNT - Enabling the SDDM Service..."
    for login_manager in lightdm gdm lxdm lxdm-gtk3; do
        if pacman -Qs "$login_manager" > /dev/null; then
            echo "disabling $login_manager..."
            sudo systemctl disable "$login_manager.service" 2>&1 | tee -a "$LOG"
        fi
    done
    sudo systemctl enable sddm &>> $INSTLOG
    sleep 2
    echo -e "$COK - Done!!"
fi

### Install shell ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like install any these fish(f)/zsh(z)/No(n) shells? (f,z,n) ' FIZSH
if [[ $FIZSH == "F" || $FIZSH == "f" ]]; then
    # install the fish shell
    echo -e "$CAC - Installing fish and components..."
    install_software fish
    install_software lsd
    install_software bat
    echo -e "$CAC - Set fish by default..."
    sudo usermod -s /usr/bin/fish $USER
    sleep 1
    echo -e "$COK - Done!!"
elif [[ $FIZSH == "Z" || $FIZSH == "z" ]]; then
    # install the zsh shell
    echo -e "$CAC - Installing zsh and components..."
    install_software zsh
    install_software zsh-syntax-highlighting
    install_software zsh-autosuggestions
    install_software lsd
    install_software bat
    echo -e "$CAC - Set zsh by default..."
    if [[ -e  ~/.zshrc ]]; then
        echo -e "$CNT Backup .zshrc file"
        mv ~/.zshrc ~/.zshrc_backup
        echo "#Create .zshrc file" > ~/.zshrc
    else
        echo "#Create .zshrc file" > ~/.zshrc
    fi
    sudo usermod -s /usr/bin/zsh $USER
    sleep 1
    echo -e "$COK - Done!!"
fi

### Install termial kitty/foot
if [[ $ISVM == *"vm"* ]]; then
    echo "---------------------------------------------------------------------------------------------------"
    echo -e "$CNT - Please note that VMs are not fully supported kitty, I recommend installing foot instead"
    echo -e "---------------------------------------------------------------------------------------------------\n"
    if [[ -e ~/.config/hypr/conf/decoration.conf ]]; then
        sed -i 's|source = ~/.config/hypr/conf/layerrule.conf|#source = ~/.config/hypr/conf/layerrule.conf|' ~/.config/hypr/hyprland.conf
        sed -i 's/active_opacity = 0.93/active_opacity = 1.0/' ~/.config/hypr/conf/decoration.conf
        sed -i 's/enabled = true/enabled = false/' ~/.config/hypr/conf/decoration.conf
    fi
    sleep 1
    echo -e "$CAC - Installing important tool for VM..."
    install_software socat
fi

read -rep $'[\e[1;33mACTION\e[0m] - Would you like install any these kitty(k)/foot(f)/No(n) terminals? (k,f,n) ' TERM
if [[ $TERM == "K" || $TERM == "k" ]]; then
    # install kitty
    echo -e "$CAC - Installing kitty..."
    install_software kitty
    echo -e "$CAC - Setting up componenets..."
    
    if [[ -e ~/.zshrc ]]; then
        echo 'alias icat="kitten icat"' >> ~/.zshrc
    elif [[ -e ~/.config/fish/config.fish ]]; then
        sed -i '5ialias icat="kitten icat"' ~/.config/fish/config.fish
    else
        echo 'alias icat="kitten icat"' >> ~/.bashrc
    fi

    sleep 1
    echo -e "$COK - Done!!"
elif [[ $TERM == "F" || $TERM == "f" ]]; then
    # install foot
    echo -e "$CAC - Installing foot and componenets..."
    install_software foot
    echo -e "$CAC - Setting up componenets..."
    mkdir -p ~/.config/foot/scripts
    cp Extras/foot.ini ~/.config/foot/scripts
    sleep 1
    echo -e "$COK - Done!!"
else
    echo "---------------------------------------------------------------"
    echo -e "$CNT - Please install a terminal before starting hyprland" -
    echo -e "---------------------------------------------------------------\n"
fi

## Copy wallpaper repo
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to have wallpaper repo? (y,n): ' IMG
if [[ $IMG == "Y" || $IMG == "y" ]]; then
    cd Extras/
    git clone https://github.com/daniel7prg/hyprWalls.git
    cd ..
    read -rep $'[\e[1;33mACTION\e[0m] - Would you like copy any these Pics(p)/Gifs(g)/AnimeGirls(a)/Minimalist(m) wallpapers? (p,g,a,m,n) ' PIC
    if [[ $PIC == "P" || $PIC == "p" ]]; then
        echo -e "$CAC - Setting up wallpapers..."
        if [[ -d ~/wallpapers/ ]]; then
            cp -r Extras/hyprWalls/wallpapers/PICs/ ~/wallpapers
            cp Extras/waiting.jpeg ~/wallpapers
        else
            mkdir -p ~/wallpapers
            cp -r Extras/hyprWalls/wallpapers/PICs/ ~/wallpapers
            cp Extras/waiting.jpeg ~/wallpapers
        fi
        echo -e "$COK - Done!!"
    elif [[ $PIC == "G" || $PIC == "g" ]]; then
        if [[ $ISVM != *"vm"* ]]; then
            echo -e "$CAC - Setting up wallpapers..."
            if [[ -d ~/wallpapers/ ]]; then
                cp -r Extras/hyprWalls/wallpapers/Gifs ~/wallpapers
                cp Extras/waiting.jpeg ~/wallpapers
            else
                mkdir -p ~/wallpapers
                cp -r Extras/hyprWalls/wallpapers/Gifs ~/wallpapers
                cp Extras/waiting.jpeg ~/wallpapers
            fi
        else
            if [[ -d ~/wallpapers/ ]]; then
                cp Extras/waiting.jpeg ~/wallpapers
            else
                mkdir -p ~/wallpapers
                cp Extras/waiting.jpeg ~/wallpapers
            fi
            echo -e "$CNT - Gifs in VM give bad performance"
        fi
        echo -e "$COK - Done!!"
    elif [[ $PIC == "A" || $PIC == "a" ]]; then
        echo -e "$CAC - Setting up wallpapers..."
        if [[ -d ~/wallpapers/ ]]; then
            cp -r Extras/hyprWalls/wallpapers/Anime_Girls/ ~/wallpapers
            cp Extras/waiting.jpeg ~/wallpapers
        else
            mkdir -p ~/wallpapers
            cp -r Extras/hyprWalls/wallpapers/Anime_Girls/ ~/wallpapers
            cp Extras/waiting.jpeg ~/wallpapers
        fi
        echo -e "$COK - Done!!"
    elif [[ $PIC == "M" || $PIC == "m" ]]; then
        echo -e "$CAC - Setting up wallpapers..."
        if [[ -d ~/wallpapers/ ]]; then
            cp -r Extras/hyprWalls/wallpapers/Minimalist/ ~/wallpapers
            cp Extras/waiting.jpeg ~/wallpapers
        else
            mkdir -p ~/wallpapers
            cp -r Extras/hyprWalls/wallpapers/Minimalist/ ~/wallpapers
            cp Extras/waiting.jpeg ~/wallpapers
        fi
        echo -e "$COK - Done!!"
    fi
    rm -r Extras/hyprWalls/
else
    if [[ -d ~/wallpapers/ ]]; then
        cp Extras/waiting.jpeg ~/wallpapers
    else
        mkdir -p ~/wallpapers
        cp Extras/waiting.jpeg ~/wallpapers
    fi
fi

### Script is done ###
echo -e "$CNT - Script had completed!"
if [[ "$ISNVIDIA" == true ]]; then 
    echo -e "$CAT - Since we attempted to setup an Nvidia GPU the script will now end and you should reboot.
    Please type 'reboot' at the prompt and hit Enter when ready."
    exit
fi

read -rep $'[\e[1;33mACTION\e[0m] - Would you like reboot now? (y,n): ' RBT
if [[ $RBT == "Y" || $RBT == "y" ]]; then
    exec systemctl reboot
else
    exit
fi