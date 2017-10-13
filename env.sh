#!/bin/bash
# ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥
# ♥
# ♥					A script made in shell to manage version and backups of my Database PostgreSQL
# ♥
# ♥					@author ovictoraurelio
# ♥					@github http://github.com/ovictoraurelio
# ♥					@website http://victoraurelio.com
# ♥
# ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ ♥ 

function inputU {
    printf "\t${wht}$1: ${blu}" 
}
function p {
    printf "\n\t${wht}$1$2$3"
}
function doing {
    printf "\n\t${blu}$1$2$3${yel}"
}
function finished {
    printf "\n\n\t${gre}$1$2$3${yel}"
}
function warn {
    printf "\n\t${yel}$1$2$3"
}
function error {
    printf "\n\n\t${red}$1$2$3${wht}"
}
function settings {	
    chmod 700 $HOME    
    gsettings reset com.canonical.Unity.Launcher favorites
    gsettings set com.canonical.Unity.Launcher favorites "$(
python << EOF
array = eval("$(gsettings get com.canonical.Unity.Launcher favorites)")
print(str(array[:3] + array[8:]))
EOF
)"	
}
function backgroundImage {
    wget -O $DIR/background.jpg http://cin.ufpe.br/~lbn/img/wallpaper.JPG
    gsettings set org.gnome.desktop.background picture-uri file://$DIR/background.jpg
}
function addShortcut {    
    doing "adding shortcut for $1"
    
    gtk-update-icon-cache -f $HOME/.local/share/icons/hicolor >/dev/null 2>&1
	desktop-file-install --dir $HOME/.local/share/applications/ "$HOME/.local/share/applications/$1"
    
    favorites=$(
python << EOF
from collections import OrderedDict
array = eval("$(gsettings get com.canonical.Unity.Launcher favorites)")
print(str(list(OrderedDict.fromkeys(array[:-3] + ["$1"] + array[-3:]))))
EOF
)
    gsettings set com.canonical.Unity.Launcher favorites "$favorites"
    
    finished "$1 added to sidebar\n"    
}

function firefoxDEV {
	doing "Installing Firefox Developer Edition"
	wget -O $DIR/firefoxdev.tar.bz2 http://victoraurelio.com/box/firefox-57.0b3.tar.bz2
	mkdir $DIR/firefoxdev
	tar -xjf $DIR/firefoxdev.tar.bz2 --strip 1 -C $DIR/firefoxdev
	$DIR/firefoxdev/firefox &
	finished "Firefox Developer Edition successfully installed"
}

function configFirefoxDEV {    
cat << EOF > $HOME/.local/share/applications/firefoxdev.desktop
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Name=Firefox Developer
Icon=$DIR/firefoxdev/browser/icons/mozicon128.png
Path=$DIR/firefoxdev
Exec=$DIR/firefoxdev/firefox
StartupNotify=false
StartupWMClass=Firefox
OnlyShowIn=Unity;
X-UnityGenerated=true
EOF
    addShortcut firefoxdev.desktop
}


function code {	
	doing "Installing vs code"
	doing "Downloading vs code"
    git clone https://github.com/levibn/linuxvs $HOME/Desktop/linuxvs
	doing "Adding settings"
	configCode
	doing "Executing vs code"
	finished "VS Code successfully installed\n"
}
function copy {
    ( cp -fRv ${@:2} | pv -elnps $(find ${@:2:(( $# - 2 ))} | wc -l) ) 2>&1 | whiptail --title "Extracting" --gauge "\nStatus complete$1..." 0 0 0
}

function nodeJS {    
    doing "installing Node.js...\n"
    wget -O $DIR/node.txz https://nodejs.org/dist/v6.11.3/node-v6.11.3-linux-x64.tar.xz
    command -v pv
    if [ $? -eq 0 ]; then 
        echo "pv is found in PATH"; 
        pv -n $DIR/node.txz  | tar -xJf - -C $DIR/node/ 
        copy "Node.js (part 1/4)" $DIR/node/*/bin $HOME/teste
        copy "Node.js (part 2/4)" $DIR/node/*/include $HOME/teste
        copy "Node.js (part 3/4)" /tmp/node*/lib $HOME/.local
        copy "Node.js (part 4/4)" /tmp/node*/share $HOME/.local
    else 
        curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh -o $HOME/Desktop/install_nvm.sh
        chmod +x $HOME/Desktop/install_nvm.sh
        bash $HOME/Desktop/install_nvm.sh
        source ~/.profile
        nvm install 8.6.0
    fi    

    finished "Node.js installed successfully!"
}



function configCode {    
    chmod +x $HOME/Desktop/linuxvs/make.sh
    .$HOME/Desktop/linuxvs/make.sh
    addShortcut code.desktop
}


function essentials {
    wht=$(tput sgr0);red=$(tput setaf 1);gre=$(tput setaf 2);yel=$(tput setaf 3);blu=$(tput setaf 4);
    if [ ! -d $HOME/apps ]; then 
        doing "Creating apps folder"
        mkdir $HOME/apps
    fi
    DIR=$HOME/apps
}

function MAIN {	
    essentials
	settings
    backgroundImage
    nodeJS  
    firefoxDEV
    configFirefoxDEV
    code
    configCode  
}
MAIN
