#!/bin/bash

# Function to download a file
download() {
    url=$1
    filename=$2
    curl -sSL "$url" -o "$filename"
}

# Function to download LocalXpose
install_localxpose() {
    if [[ -e "./loclx" ]]; then
        printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Localxpose already installed.${RS}"
    else
        printf "\n${RS} ${CR}[${CW}-${CR}]${CC} Installing Localxpose...${RS}"
        if [[ ("$architecture" == *'arm'*) || ("$architecture" == *'Android'*) ]]; then
            download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm.zip' 'loclx'
        elif [[ "$architecture" == *'aarch64'* ]]; then
            download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm64.zip' 'loclx'
        elif [[ "$architecture" == *'x86_64'* ]]; then
            download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-amd64.zip' 'loclx'
        else
            download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-386.zip' 'loclx'
        fi
    fi
}

# Function for LocalXpose authentication
localxpose_auth() {
    ./loclx -help > /dev/null 2>&1 &
    { logo; sleep 1; }
    [ -d ".localxpose" ] && auth_f=".localxpose/.access" || auth_f="$HOME/.localxpose/.access"
    [ -d "/data/data/com.termux/files/home" ] && status=$(termux-chroot ./loclx account status) || status=$(./loclx account status)

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

# Function to display menu
menu() {
    clear
    echo "=== LocalXpose Menu ==="
    echo "1. Install LocalXpose"
    echo "2. Configure LocalXpose authentication"
    echo "3. Exit"
    read -p "Enter your choice: " choice
    case $choice in
        1) install_localxpose ;;
        2) localxpose_auth ;;
        3) exit ;;
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
