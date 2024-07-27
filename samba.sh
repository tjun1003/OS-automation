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

install_samba() {
    check_installation $1
    if [ $? -eq 0 ]; then
        echo "Service $1 is installed."
    else
        echo "Service $1 is not installed. Installing now..."
        sudo dnf install -y $1
    fi
}

write_config_file(){

cat << EOF > "/etc/samba/smb.conf"

EOF

}

write_share_file(){

cat << EOF > "/etc/samba/shares.conf"

EOF

}


#--------------Main-------------------
chmod +x "$0"
switch_to_root
install_samba samba
sudo cd /etc/samba
sudo mv smb.conf smb.conf.bak
write_config_file
write_share_file
sudo mkdir -p /share/public_files
sudo mkdir /share/private_files
sudo groupadd --system smbgroup
sudo useradd --system --no-create-home --group smbgroup -s /bin/false smbuser
sudo chown -R smbuser:smbgroup /share
sudo chmod -R g+w /share
sudo systemctl start smb
sudo systemctl enable smb
echo "Done configuration"