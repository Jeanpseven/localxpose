#!/bin/bash

# Function to download and extract LocalXpose
install_localxpose() {
    if [[ -e "/usr/share/loclx/loclx" ]]; then
        printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Localxpose already installed.${RS}"
    else
        printf "\n${RS} ${CR}[${CW}-${CR}]${CC} Installing Localxpose...${RS}"
        if [[ ("$architecture" == *'arm'*) || ("$architecture" == *'Android'*) ]]; then
            download_and_extract 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm.zip' '/usr/share/loclx'
        elif [[ "$architecture" == *'aarch64'* ]]; then
            download_and_extract 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm64.zip' '/usr/share/loclx'
        elif [[ "$architecture" == *'x86_64'* ]]; then
            download_and_extract 'https://api.localxpose.io/api/v2/downloads/loclx-linux-amd64.zip' '/usr/share/loclx'
        else
            download_and_extract 'https://api.localxpose.io/api/v2/downloads/loclx-linux-386.zip' '/usr/share/loclx'
        fi
    fi
}

# Function to download and extract archive
download_and_extract() {
    url=$1
    directory=$2
    tmp_dir=$(mktemp -d)
    curl -sSL "$url" -o "$tmp_dir/loclx.zip" &&
    unzip -qq "$tmp_dir/loclx.zip" -d "$tmp_dir" &&
    sudo mkdir -p "$directory" &&
    sudo mv "$tmp_dir"/* "$directory" &&
    sudo chmod +x "$directory/loclx" &&
    rm -rf "$tmp_dir"
}

# Function for LocalXpose authentication
localxpose_auth() {
    /usr/share/loclx/loclx -help > /dev/null 2>&1 &
    [ -d ".localxpose" ] && auth_f=".localxpose/.access" || auth_f="$HOME/.localxpose/.access"
    [ -d "/data/data/com.termux/files/home" ] && status=$(termux-chroot /usr/share/loclx/loclx account status) || status=$(/usr/share/loclx/loclx account status)

    if [[ $status == *"Error"* ]]; then
        echo -e "\n${CR} [${CW}!${CR}]${CG} Create an account on ${CY}localxpose.io${CG} & copy the token\n"
        sleep 3
        read -p "${CR} [${CW}?${CR}]${CY} Input Localxpose Token :${CY} " loclx_token
        if [[ ${#loclx_token} -lt 10 ]]; then
            echo -e "\n${CR} [${CQ}!${CR}]${CR} You have to input Localxpose Token."
            sleep 2; menu;
        else
            echo -n "$loclx_token" > "$auth_f" 2> /dev/null
        fi
    fi
}

# Function to start LocalXpose with a public port
start_localxpose() {
    read -p "Enter local port to expose: " local_port
    read -p "Enter public port to use: " public_port
    /usr/share/loclx/loclx tcp "$local_port" -p "$public_port" -v &
    public_url="https://$USER.localxpose.me:$public_port"
    echo "Access your hosted service at: $public_url"
    echo "Monitor your hosted service at: https://localxpose.io/overview"
}

# Function to display menu
menu() {
    clear
    echo "=== LocalXpose Menu ==="
    echo "1. Install LocalXpose"
    echo "2. Configure LocalXpose authentication"
    echo "3. Start LocalXpose with public port"
    echo "4. Exit"
    read -p "Enter your choice: " choice
    case $choice in
        1) install_localxpose ;;
        2) localxpose_auth ;;
        3) start_localxpose ;;
        4) exit ;;
        *) echo "Invalid choice. Please enter a valid option." ;;
    esac
}

# Main function
main() {
    while true; do
        menu
        read -p "Press Enter to continue..."
    done
}

# Start the script
main
