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

install_mysql() {
    check_installation $1
    if [ $? -eq 0 ]; then
        echo "Service $1 is installed."
    else
        echo "Service $1 is not installed. Installing now..."
        mysql_secure_installation_auto
    fi
}

mysql_secure_installation_auto() {
  expect <<EOF
  set timeout 10
  set password $MYSQL_ROOT_PASSWORD

  spawn sudo mysql_secure_installation

  expect "Enter password for user root:"
  send "$password\r"

  expect "New password:"
  send "newpassword\r"

  expect "Re-enter new password:"
  send "newpassword\r"

  expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
  send "n\r"

  expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
  send "y\r"

  expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
  send "y\r"

  expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
  send "y\r"

  expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
  send "y\r"

  expect eof
EOF
}
#--------------Main-------------------
chmod +x "$0"
switch_to_root
sudo dnf install -y expect
install_mysql mysql-server
sudo systemctl start mysqld
sudo systemctl enable mysqld
echo "Done configuration"