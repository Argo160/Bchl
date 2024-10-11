#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m' # No Color

# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

install_jq() {
    if ! command -v jq &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}jq is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y jq
        else
            echo -e "${RED}Error: Unsupported package manager. Please install jq manually.${NC}\n"
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}

require_command(){
    install_jq
    if ! command -v pv &> /dev/null; then
        echo "pv could not be found, installing it..."
        sudo apt update
        sudo apt install -y pv
    fi
}

menu(){
    clear
    SERVER_IP=$(hostname -I | awk '{print $1}')
    SERVER_COUNTRY=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.country')
    SERVER_ISP=$(curl -sS "http://ip-api.com/json/$SERVER_IP" | jq -r '.isp')
    BACK_CORE=$(check_status)
    echo "+--------------------------------------------------------------------------------------------------------------------------------------+"                                                                                                                                                                                        
    echo -e "|${GREEN}Server Country    |${NC} $SERVER_COUNTRY"
    echo -e "|${GREEN}Server IP         |${NC} $SERVER_IP"
    echo -e "|${GREEN}Server ISP        |${NC} $SERVER_ISP"
    echo -e "|${GREEN}Backhaul          |${NC} $BACK_CORE"
    echo "+--------------------------------------------------------------------------------------------------------------------------------------+"                                                                                                
    echo -e "|${YELLOW}Please choose an option:${NC}"
    echo "+--------------------------------------------------------------------------------------------------------------------------------------+"                                                                                                
    echo -e $1
    echo "+--------------------------------------------------------------------------------------------------------------------------------------+"                                                                                                
    echo -e "\033[0m"
}

MAIN(){
    clear
    menu "| 1  - Install Backhaul Core \n| 2  - Setup Tunnel \n| 3  - Unistall \n| 0  - Exit"
    read -p "Enter your choice: " choice
    
    case $choice in
        1)
            BACKCORE
        ;;
        2)
            TUNNEL
        ;;
        3)
            rm -rf backhaul config.toml /etc/systemd/system/backhaul.service
            sudo systemctl daemon-reload

        ;;
        0)
            echo -e "${GREEN}Exiting program...${NC}"
            exit 0
        ;;
        *)
            echo "Invalid choice. Please try again."
            read -p "Press any key to continue..."
        ;;
    esac
}


BACKCORE(){

    ## Download from github
    wget https://github.com/Musixal/Backhaul/releases/download/v0.1.1/backhaul_linux_amd64.tar.gz

    # Permission File 
    chmod +x backhaul

    # exteract file 
    tar -xzvf backhaul_linux_amd64.tar.gz

    # move
    mv backhaul /usr/bin/backhaul
    
    # clear screen
    clear

    echo $'\e[32m Backhaul Core in 3 seconds... \e[0m' && sleep 1 && echo $'\e[32m2... \e[0m' && sleep 1 && echo $'\e[32m1... \e[0m' && sleep 1 && {
        MAIN
    }    
    
}


check_status() {
    if [ -e /usr/bin/backhaul ]; then
        echo -e ${GREEN}"installed"${NC}
    else
        echo -e ${RED}"Not installed"${NC}
    fi
}

TUNNEL(){
    clear
    menu "| 1  - IRAN \n| 2  - KHAREJ  \n| 0  - Exit"
    read -p "Enter your choice: " choice
    
    case $choice in
        1)

            echo "Please choose a protocol (tcp, ws, or tcpmux):"
            read protocol

            if [[ "$protocol" == "tcp" ]]; then
                result="tcp"
            elif [[ "$protocol" == "ws" ]]; then
                result="ws"
            elif [[ "$protocol" == "tcpmux" ]]; then
                result="tcpmux"
            else
                result="Invalid choice. Please choose between tcp, ws, or tcpmux."
            fi

            read -p "Enter Token : " token
            read -p "Do you want nodelay (true/false)? " nodelay

			read -p "How many port mappings do you want to add?" port_count



ports=$(IRAN_PORTS "$port_count")

cat <<EOL > config.toml
[server]# Local, IRAN
bind_addr = "0.0.0.0:3080"
transport = "${protocol}"
token = "${token}"
nodelay = ${nodelay}
keepalive_period = 20
channel_size = 2048
connection_pool = 16
mux_session = 1
log_level = "info"
${ports}
EOL

        backhaul -c config.toml
        create_backhaul_service
        ;;
        2)

            echo "Please choose a protocol (tcp, ws, or tcpmux):"
            read protocol

            if [[ "$protocol" == "tcp" ]]; then
                result="tcp"
            elif [[ "$protocol" == "ws" ]]; then
                result="ws"
            elif [[ "$protocol" == "tcpmux" ]]; then
                result="tcpmux"
            else
                result="Invalid choice. Please choose between tcp, ws, or tcpmux."
            fi

            read -p "Enter Token : " token
            read -p "Do you want nodelay (true/false) ? " nodelay
			read -p "Please enter Remote IP : " remote_ip

cat <<EOL > config.toml
[client]
remote_addr = "${remote_ip}:3080"
transport = "${protocol}"
token = "${token}"
nodelay = ${nodelay}
keepalive_period = 20
retry_interval = 1
log_level = "info"
mux_session = 1
EOL

        # backhaul -c config.toml

        create_backhaul_service

        ;;
        0)
            echo -e "${GREEN}Exiting program...${NC}"
            exit 0
        ;;
        *)
            echo "Invalid choice. Please try again."
            read -p "Press any key to continue..."
        ;;
    esac
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

create_backhaul_service() {
    service_file="/etc/systemd/system/backhaul.service"

    echo "[Unit]" > "$service_file"
    echo "Description=Backhaul Reverse Tunnel Service" >> "$service_file"
    echo "After=network.target" >> "$service_file"
    echo "" >> "$service_file"
    echo "[Service]" >> "$service_file"
    echo "Type=simple" >> "$service_file"
    echo "ExecStart=/root/backhaul -c /root/config.toml" >> "$service_file"
    echo "Restart=always" >> "$service_file"
    echo "RestartSec=3" >> "$service_file"
    echo "LimitNOFILE=1048576" >> "$service_file"
    echo "" >> "$service_file"
    echo "[Install]" >> "$service_file"
    echo "WantedBy=multi-user.target" >> "$service_file"

    # Reload systemd daemon to recognize new service
    systemctl daemon-reload

    # Optionally enable and start the service
    systemctl enable backhaul.service
    systemctl start backhaul.service

    echo "backhaul.service created and started."
}

require_command
MAIN
