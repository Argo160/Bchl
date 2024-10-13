#!/bin/bash

CORE(){
    clear
    if [ -e /usr/bin/backhaul ]; then
        echo -e ${GREEN}"installed"${NC}
    else
        echo -e ${RED}"Not installed"${NC}
        mkdir backhaul
        cd backhaul
        if [[ "$(uname -m)" == "x86_64" ]]; then
            wget https://github.com/Musixal/Backhaul/releases/download/v0.1.1/backhaul_linux_amd64.tar.gz -O backhaul_linux.tar.gz
        elif [[ "$(uname -m)" == "aarch64" ]]; then
            wget https://github.com/Musixal/Backhaul/releases/download/v0.4.5/backhaul_linux_arm64.tar.gz -O backhaul_linux.tar.gz
        fi    
        tar -xzvf backhaul_linux.tar.gz
        rm backhaul_linux.tar.gz
        chmod +x backhaul
        mv backhaul /usr/bin/backhaul
        cd
        mkdir backhaulconfs
        cd backhaulconfs
        clear
    fi
}
tcp-ws() {

}
Iran_bc() {
    clear
    cd
    cd backhaulconfs
    read -p "Tunnel System Name : " tnlsys
    read -p "Enter Token : " token
    read -p "How many port mappings do you want to add?" port_count
    ports=$(IRAN_PORTS "$port_count")
    protocol_selection
    if [ "$protocol" == "tcp" ] || [ "$protocol" == "ws" ]; then
#    if [[ "$protocol" == "tcp" || "$protocol" == "ws" ]]; then
        tcp-ws
    elif [[ "$protocol" == "ws" ]]; then
        result="ws"
    elif [[ "$protocol" == "tcpmux" ]]; then
        result="tcpmux"
    else
        result="Invalid choice. Please choose between tcp, ws, or tcpmux."
    fi    
}

IRAN_PORTS() {
    ports=()
    for ((i=1; i<=$1; i++))
    do
        read -p "Enter LocalPort for mapping $i: " local_port

        read -p "Enter RemotePort for mapping $i: " remote_port

        ports+=("$local_port=$remote_port")
    done
    echo "ports = ["
    for port in "${ports[@]}"
    do
        echo "   \"$port\","
    done
    echo "]"
}

Kharej_bc() {
    clear
    protocol_selection
}
protocol_selection() {
    clear
    while true; do
        clear
        echo "Menu:"
        echo "1  - TCP"
        echo "2  - WS"
        echo "3  - WSS"
        echo "4  - TCP MUX"
        echo "5  - WS MUX"
        echo "6  - WSS MUX"
        echo "0  - Return"
        read -p "Enter your choice: " protocol
        case $choice in
            1) pp=3000;;
                protocol=tcp;;
            2) pp=8080;;
                protocol=ws;;
            3) pp=8443
                protocol=wss;;
            4) pp=3000
                protocol=tcpmux;;
            5) pp=8080
                protocol=wsmux;;
            6) pp=8443
                protocol=wssmux;;
            0) Break;;    
            *) echo "Invalid choice. Please enter a valid option.";;
        esac
    done
}

protocol=cc
pp=0
token=0
port_count=0
ports=0
# Main menu
# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1
while true; do
clear
    echo "Menu:"
    echo "1  - Install Core"
    echo "2  - Setup Tunnel"
    echo "3  - Unistall"
    echo "0  - Exit"
    read -p "Enter your choice: " choice
    case $choice in
        1) CORE;;
        2) #TUNNEL
            while true; do
                clear
                echo "TUNNEL SETUP"
                echo "1  - This is Iran"
                echo "2  - This is Kharej"
                echo "3  - Return"
                read -p "Enter your choice: " tl_choice
                case $tl_choice in
                    1) Iran_bc;;
                    2) Kharej_bc;;
                    3) Break;;
                    *) echo "Invalid choice. Please enter a valid option.";;
                esac
            done;;
        3) UNINSTALL;;
        0) echo "Exiting..."; exit;;
        *) echo "Invalid choice. Please enter a valid option.";;
    esac
done
