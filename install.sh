#!/bin/bash

dependencies="curl wine tar wget gdown"
install_folder="$HOME/.photoshop"
wine_folder="$install_folder/wine"

# Colours
yellow="\e[1;93m"
red="\e[31m"
green="\e[1;32m"
bold="\e[1m"
reset="\e[0m"

export WINEPREFIX="$PWD/Ps-prefix"

print_step() {
    echo -e "\n\t${yellow}*${reset} ${bold}$1${reset}"
}

print_success() {
    echo -e "${green}${reset} ${bold}$1${reset}"
}

print_error() {
    echo -e "\n${red} $1${reset}"
}

print_step "Starting Adobe Photoshop CC 2021 (v22) installer..."


# Get install folder
echo -e "\nWhere do you want to install Photoshop?"
read -rei "$install_folder" install_folder


# Check if already installed
if [ -d "$install_folder" ]; then
    print_error "Photoshop seem already installed, override it? (y/N)"
    read -rn 1
    if ! [[ $REPLY =~ [Yy] ]]; then
        echo -e "\n${red}Aborting installation!${reset}"
        exit 1
    fi
fi


# Dependencies check
print_step "Checking for dependencies"
for name in $dependencies
do
    # [[ $(command -v $name) ]] && echo -e "${green}Found $name${reset}"|| { echo -e "$name needs to be installed. Use 'sudo apt-get install $name'";deps=1; }
    [[ $(command -v "$name") ]] || { echo -e "${red}'$name'${reset} needs to be installed."; dep_error=1; }
done
[[ $dep_error -ne 1 ]] && print_success "OK" || { echo -en "\nInstall the above and rerun this script\n"; exit 1; }


# Optional add-ons
print_step "Optional add-ons"
install_camera_raw=0
install_vdk3d=0

prompt_and_set_install() {
    local install_var=$1
    read -rp "- Install $2? (y/N)" -n 1
    echo ""
    if [[ $REPLY =~ [Yy] ]]; then
        eval "$install_var=1"
        print_success "selected for install"
    fi
}

prompt_and_set_install install_camera_raw "Adobe Camera Raw"
prompt_and_set_install install_vdk3d "vdk3d"


#Function to download file and check for its integrity
check_and_download() {
    local file_url=$1 #URL of the file to be downloaded
    local file_path=$2 #Local path where the file will be stored
    local file_name=$(basename $file_url) #Extract the file name from the url
    local md5_path=".$file_name.md5" #path of the md5 file

    #Check if the file already exists
    if ! [ -f $file_path ]; then
        echo "Downloading $file_name..."
        #Check if the file should be downloaded using gdown
        if [ $file_url == "gdown" ]; then
            gdown "$3" -O $file_path
        else
            curl -L $file_url > $file_path
        fi
    #Check if the md5sum of the file matches the expected value
    elif md5sum --status -c $md5_path; then
        echo -e "The file $file_name is available"
    else
        echo ""
        choice="0"
        read -p "The \"$file_name\" file is corrupted, would you like to remove and re-download it? (y/n): " choice
        if [ $choice = "y" ]; then
            rm $file_path
            echo ""
            echo "Removed corrupted file and downloading again..."
            echo ""
            #Check if the file should be downloaded using gdown
            if [ $file_url == "gdown" ]; then
                gdown "$3" -O $file_path
            else
                curl -L $file_url > $file_path
            fi
        else
            echo ""
            echo "Aborting installation!"
            echo ""
            exit 1
        fi
    fi
}

#Remove the existing PS prefix and create a new one
print_step "Making PS prefix..."
rm -rf $PWD/Ps-prefix
mkdir $PWD/Ps-prefix

#Creating the scripts directory
mkdir -p scripts

#Downloading winetricks and making it executable
print_step "Downloading winetricks and making executable if not already downloaded..."
check_and_download "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" "scripts/winetricks"
chmod +x scripts/winetricks

#Creating the installation files directory
print_step "Downloading Photoshop files and components if not already downloaded..."
mkdir -p installation_files

#Downloading ps_components.tar.xz
check_and_download "gdown" "installation_files/ps_components.tar.xz" "1esUAZkejzJARub9cessbVeUCDlzzzcQG"

#Checking if the user wants to install camera raw and download the installer
if [ $install_camera_raw = "y" ]; then
    print_step "Downloading Camera Raw installer if not already downloaded..."
    check_and_download "https://download.adobe.com/pub/adobe/photoshop/cameraraw/win/12.x/CameraRaw_12_2_1.exe" "install"
fi

# clear wine folder?

print_step "Making PS prefix..."
rm -rf $PWD/Ps-prefix
mkdir $PWD/Ps-prefix
sleep 1

mkdir -p scripts

print_step "Downloading winetricks and making executable if not already downloaded..."
sleep 1
wget -nc --directory-prefix=scripts/ https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x scripts/winetricks

sleep 1

print_step "Downloading Photoshop files and components if not already downloaded..."
sleep 1
mkdir -p installation_files

if ! [ -f installation_files/ps_components.tar.xz ]; then
    gdown "1esUAZkejzJARub9cessbVeUCDlzzzcQG" -O installation_files/ps_components.tar.xz
else
    if md5sum --status -c .ps_components.md5; then
        echo -e "The file ps_components.tar.xz is available"
    else
        echo ""
        choice="0"
        read -p "The \"ps_components.tar.xz\" file is corrupted, would you like to remove and re-download it? (y/n): " choice
        if [ $choice = "y" ]; then
            rm installation_files/ps_components.tar.xz
            echo ""
            echo "Removed corrupted file and downloading again..."
            echo ""
            gdown "1esUAZkejzJARub9cessbVeUCDlzzzcQG" -O installation_files/ps_components.tar.xz
        else
            echo ""
            echo "Aborting installation!"
            echo ""
            exit 1
        fi
    fi
fi


if [ $install_camera_raw = "y" ]; then
    echo ""
    print_step "Downloading Camera Raw installer if not already downloaded..."
    echo ""
    if ! [ -f installation_files/CameraRaw_12_2_1.exe ]; then
        curl -L "https://download.adobe.com/pub/adobe/photoshop/cameraraw/win/12.x/CameraRaw_12_2_1.exe" > installation_files/CameraRaw_12_2_1.exe
        elif md5sum --status -c .camera_raw.md5; then
        echo -e "The file CameraRaw_12_2_1.exe is available"
    else
        echo ""
        choice="0"
        read -p "The \"CameraRaw_12_2_1.exe\" file is corrupted, would you like to remove and re-download it? (y/n): " choice
        if [ $choice = "y" ]; then
            rm installation_files/CameraRaw_12_2_1.exe
            echo ""
            echo "Removed corrupted file and downloading again..."
            echo ""
            curl -L "https://download.adobe.com/pub/adobe/photoshop/cameraraw/win/12.x/CameraRaw_12_2_1.exe" > installation_files/CameraRaw_12_2_1.exe
        else
            echo ""
            echo "Aborting installation!"
            echo ""
            exit 1
        fi
    fi
fi

sleep 1

print_step "Extracting files..."
sleep 1
rm -fr installation_files/Adobe\ Photoshop\ 2021 installation_files/redist installation_files/x64 installation_files/x86
tar -xvf installation_files/ps_components.tar.xz -C installation_files/
sleep 1


print_step "Booting & creating new prefix"
sleep 1
wineboot
sleep 1

print_step "Setting win version to win10"
sleep 1
./scripts/winetricks win10
sleep 1

print_step "Installing & configuring winetricks components..."
./scripts/winetricks fontsmooth=rgb gdiplus msxml3 msxml6 atmlib corefonts dxvk
sleep 1

print_step "Installing redist components..."
sleep 1

wine installation_files/redist/2010/vcredist_x64.exe /q /norestart
wine installation_files/redist/2010/vcredist_x86.exe /q /norestart
wine installation_files/redist/2012/vcredist_x86.exe /install /quiet /norestart
wine installation_files/redist/2012/vcredist_x64.exe /install /quiet /norestart
wine installation_files/redist/2013/vcredist_x86.exe /install /quiet /norestart
wine installation_files/redist/2013/vcredist_x64.exe /install /quiet /norestart
wine installation_files/redist/2019/VC_redist.x64.exe /install /quiet /norestart
wine installation_files/redist/2019/VC_redist.x86.exe /install /quiet /norestart

sleep 1


if [ $vdk3d = "y" ]; then
    print_step "Installing vdk3d proton..."
    sleep 1
    ./scripts/setup_vkd3d_proton.sh install
    sleep 1
fi

print_step "Making PS directory and copying files..."

sleep 1

mkdir $PWD/Ps-prefix/drive_c/Program\ Files/Adobe
mv installation_files/Adobe\ Photoshop\ 2021 $PWD/Ps-prefix/drive_c/Program\ Files/Adobe/Adobe\ Photoshop\ 2021

sleep 1

print_step "Copying launcher files..."

sleep 1
rm -f scripts/launcher.sh
rm -f scripts/photoshop.desktop

echo "#\!/bin/bash
cd \"$PWD/Ps-prefix/drive_c/Program Files/Adobe/Adobe Photoshop 2021/\"
WINEPREFIX=\"$PWD/Ps-prefix\" wine photoshop.exe $1" > scripts/launcher.sh


echo "[Desktop Entry]
Name=Photoshop CC
Exec=bash -c '$PWD/scripts/launcher.sh'
Type=Application
Comment=Photoshop CC 2021
Categories=Graphics;2DGraphics;RasterGraphics;Production;
Icon=$PWD/images/photoshop.svg
StartupWMClass=photoshop.exe
MimeType=image/png;image/psd;" > scripts/photoshop.desktop

chmod u+x scripts/launcher.sh
chmod u+x scripts/photoshop.desktop

rm -f ~/.local/share/applications/photoshop.desktop
mv scripts/photoshop.desktop ~/.local/share/applications/photoshop.desktop

sleep 1

if [ $cameraraw = "y" ]; then
    print_step "Installing Adobe Camera Raw, please follow the instructions on the installer window..."
    sleep 1
    wine installation_files/CameraRaw_12_2_1.exe
    sleep 1
fi

print_step "Adobe Photoshop CC 2021 (v22) Installation has been completed!"
echo -e "Use this command to run Photoshop from the terminal:\n\n${yellow}bash -c '$PWD/scripts/launcher.sh'${reset}"
