#!/bin/bash

switch_to_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "You are not root. Trying to switch to root..."
        sudo -S su - root
    else
        echo "You are already root."
    fi
}

check_installation() {
    service=$1
    if systemctl list-unit-files --type=service | grep -q "^$service.service"; then
        return 0
    else
        return 1
    fi
}

install_firewalld() {
    check_installation $1
    if [ $? -eq 0 ]; then
        echo "Service $1 is installed."
    else
        echo "Service $1 is not installed. Installing now..."
        sudo dnf install -y $1
    fi
}

#--------------Main-------------------
chmod +x "$0"
switch_to_root
install_firewalld firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-service=smtp --permanent
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --zone=public --add-service=mysql --permanent
sudo firewall-cmd --zone=public --add-service=samba --permanent
sudo firewall-cmd --reload
sudo systemctl restart firewalld
echo "Done configuration"