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

install_postfix() {
    check_installation $1
    if [ $? -eq 0 ]; then
        echo "Service $1 is installed."
    else
        echo "Service $1 is not installed. Installing now..."
        sudo dnf install -y $1
    fi
}

change_file() {
    path="/etc/postfix/main.cf"

    sudo sed -i 's/^#myhostname = host.domain.tld/myhostname = mail.logistic.com/' "$path"
    sudo sed -i 's/^#mydomain = domain.tld/mydomain = logistic.com/' "$path"
    sudo sed -i 's/^#myorigin = $mydomain/myorigin = $mydomain/' "$path"
    sudo sed -i 's/^inet_interfaces = all/inet_interfaces = localhost/' "$path"
    sudo sed -i 's/^mydestination = $myhostname, localhost.$mydomain, localhost/mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain/' "$path"
}

#--------------Main-------------------
chmod +x "$0"
switch_to_root
install_postfix postfix
sudo systemctl start postfix
sudo systemctl enable postfix
sudo firewall-cmd --permanent --add-service=smtp
sudo firewall-cmd --reload
change_file
sudo systemctl restart postfix
echo "Done configuration"
