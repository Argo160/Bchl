CORE(){
    mkdir backhaul
    cd backhaul
    wget https://github.com/Musixal/Backhaul/releases/download/v0.1.1/backhaul_linux_amd64.tar.gz
    tar -xzvf backhaul_linux_amd64.tar.gz
    rm backhaul_linux_amd64.tar.gz
    chmod +x backhaul
    mv backhaul /usr/bin/backhaul
    clear
    echo $'\e[32m Backhaul Core in 3 seconds... \e[0m' && sleep 1 && echo $'\e[32m2... \e[0m' && sleep 1 && echo $'\e[32m1... \e[0m' && sleep 1 && {
    }    
}

# Main menu
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
        2) TUNNEL;;
        3) UNINSTALL;;
        0) echo "Exiting..."; exit;;
        *) echo "Invalid choice. Please enter a valid option.";;
    esac
done
