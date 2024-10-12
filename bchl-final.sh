CORE(){
    clear
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
    clear
    echo $'\e[32m Backhaul Core in 3 seconds... \e[0m' && sleep 1 && echo $'\e[32m2... \e[0m' && sleep 1 && echo $'\e[32m1... \e[0m' && sleep 1 && {
    }    
}
Iran_bc() {
    clear
    protocol_selection
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
        echo "4  - TCP Multiplexing"
        echo "5  - WS Multiplexing"
        echo "6  - WSS Multiplexing"
        echo "0  - Return"
        read -p "Enter your choice: " protocol
        case $choice in
            1) pp=3000
            2) pp=8080    
            3) pp=8443
            4) pp=3000    
            5) pp=8080
            6) pp=8443    
            0) Break;;    
            *) echo "Invalid choice. Please enter a valid option.";;
        esac
    done
}

protocol=cc
pp=0
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
