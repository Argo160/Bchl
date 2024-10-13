#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
plain='\033[0m'
NC='\033[0m' # No Color

CORE(){
    clear
    if [ -e /usr/bin/backhaul ]; then
        echo -e ${GREEN}"installed"${NC}
        read -n 1 -s -r -p "Press any key to continue"
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
cat <<EOL > "$bchlName"
[server]# Local, IRAN
bind_addr = "0.0.0.0:$pp"
transport = "${protocol}"
token = "${token}"
channel_size = 2048
keepalive_period = 75
heartbeat = 40
nodelay = true
sniffer = false 
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
${ports}
EOL

    backhaul -c "$bchlName"
    create_backhaul_service
}

tcpws-mux() {
    clear
cat <<EOL > "$bchlName"
[server]# Local, IRAN
bind_addr = "0.0.0.0:$pp"
transport = "${protocol}"
token = "${token}"
channel_size = 2048
keepalive_period = 75
heartbeat = 40
nodelay = true
mux_con = 8
mux_version = 1
mux_framesize = 32768 
mux_recievebuffer = 4194304
mux_streambuffer = 65536 
sniffer = false 
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
${ports}
EOL

    backhaul -c "$bchlName"
    create_backhaul_service    
}

wss() {
    clear
cat <<EOL > "$bchlName"
[server]# Local, IRAN
bind_addr = "0.0.0.0:$pp"
transport = "${protocol}"
token = "${token}"
channel_size = 2048
keepalive_period = 75
heartbeat = 40
nodelay = true
tls_cert = "$crtpath"      
tls_key = "$keypath"
sniffer = false 
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
${ports}
EOL

    backhaul -c "$bchlName"
    create_backhaul_service
}

wssmux() {
    clear
cat <<EOL > "$bchlName"
[server]# Local, IRAN
bind_addr = "0.0.0.0:$pp"
transport = "${protocol}"
token = "${token}"
channel_size = 2048
keepalive_period = 75
heartbeat = 40
nodelay = true
mux_con = 8
mux_version = 1
mux_framesize = 32768 
mux_recievebuffer = 4194304
mux_streambuffer = 65536 
tls_cert = "$crtpath"      
tls_key = "$keypath"
sniffer = false 
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
${ports}
EOL

    backhaul -c "$bchlName"
    create_backhaul_service

}

Iran_bc() {
    clear
    echo "If you need wss then before running this script make sure of having tls files ready"
    read -p "your cert file path: " crtpath
    read -p "your key file path: " keypath
    cd
    cd backhaulconfs
    echo "your current tunnel configs are:"
    for file in *.toml; do
        echo "${file%.toml}"
    done
    read -p "Your New Tunnel System Name : " tnlsys
    bchlName="$tnlsys.toml"
    read -p "Enter Token : " token
    read -p "How many port mappings do you want to add?" port_count
    ports=$(IRAN_PORTS "$port_count")
    protocol_selection
    if [ "$protocol" == "tcp" ] || [ "$protocol" == "ws" ]; then
#    if [[ "$protocol" == "tcp" || "$protocol" == "ws" ]]; then
        tcp-ws
    elif [ "$protocol" == "tcpmux" ] || [ "$protocol" == "wsmux" ]; then
        tcpws-mux
    elif [[ "$protocol" == "wss" ]]; then
        wss
    elif [[ "$protocol" == "wssmux" ]]; then
        wssmux
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

create_backhaul_service() {
    service_file="/etc/systemd/system/$tnlsys.service"

    echo "[Unit]" > "$service_file"
    echo "Description=Backhaul Reverse Tunnel Service" >> "$service_file"
    echo "After=network.target" >> "$service_file"
    echo "" >> "$service_file"
    echo "[Service]" >> "$service_file"
    echo "Type=simple" >> "$service_file"
    echo "ExecStart=/root/backhaul -c /root/backhaulconfs/$bchlName" >> "$service_file"
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

tcp-ws-wss-kh() {
cat <<EOL > "$bchlName"
[client]
remote_addr = "${remote_ip}:$pp"
transport = "${protocol}"
token = "${token}"
connection_pool = 8
keepalive_period = 75
dial_timeout = 10
retry_interval = 3
nodelay = true
sniffer = false 
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
EOL

    backhaul -c "$bchlName"
    create_backhaul_service
}

tcpws-mux-kh() {
cat <<EOL > "$bchlName"
[client]
remote_addr = "${remote_ip}:$pp"
transport = "${protocol}"
token = "${token}"
connection_pool = 8
keepalive_period = 75
dial_timeout = 10
retry_interval = 3
nodelay = true
mux_version = 1
mux_framesize = 32768 
mux_recievebuffer = 4194304
mux_streambuffer = 65536  
sniffer = false 
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
EOL

    backhaul -c "$bchlName"
    create_backhaul_service


}

Kharej_bc() {
    clear
    protocol_selection
    read -p "Please enter Remote IP/domain : " remote_ip
    read -p "Your New Tunnel System Name : " tnlsys
    bchlName="$tnlsys.toml"
    read -p "Enter Token : " token
    
    if [ "$protocol" == "tcp" ] || [ "$protocol" == "ws" ] || [ "$protocol" == "wss" ]; then
#    if [[ "$protocol" == "tcp" || "$protocol" == "ws" ]]; then
        tcp-ws-wss-kh
    elif [ "$protocol" == "tcpmux" ] || [ "$protocol" == "wsmux" ] || [ "$protocol" == "wssmux" ]; then
        tcpws-mux-kh
    else
        result="Invalid choice. Please choose between tcp, ws, or tcpmux."
    fi        
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
            1) pp=3000
                protocol=tcp
                break;;
            2) pp=8080
                protocol=ws
                break;;
            3) pp=8443
                protocol=wss
                break;;
            4) pp=3000
                protocol=tcpmux
                break;;
            5) pp=8080
                protocol=wsmux
                break;;
            6) pp=8443
                protocol=wssmux
                break;;
            0) break;;    
            *) echo "Invalid choice. Please enter a valid option.";;
        esac
    done
}

UNINSTALL() {
    cd /etc/systemd/system/
    for file in *.toml; do
        echo "${file%.toml}"
        rm -rf /etc/systemd/system/"$file.service"
    done
    read -p "Name of the system to be deleted :" sysdel 
    rm -rf backhaul /root/backhaulconfs "$sysdel.toml" 
    sudo systemctl daemon-reload

}

protocol=cc
pp=0
token=0
port_count=0
ports=0
tnlsys=0
bchlName=z.toml
crtpath=q
keypath=q
# Main menu
# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1
while true; do
clear
    echo "Menu:"
    echo "1  - Install Core"
    echo "2  - Setup Tunnel"
   # echo "3  - Unistall"
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
                    3) break;;
                    *) echo "Invalid choice. Please enter a valid option.";;
                esac
            done;;
        3) UNINSTALL;;
        0) echo "Exiting..."; exit;;
        *) echo "Invalid choice. Please enter a valid option.";;
    esac
done
