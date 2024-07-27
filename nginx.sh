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

install_nginx() {
    check_installation $1
    if [ $? -eq 0 ]; then
        echo "Service $1 is installed."
    else
        echo "Service $1 is not installed. Installing now..."
        sudo dnf install -y $1
    fi
}

write_html_file() {

cat << EOF > "/srv/logistic.com/html/UI.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <style>
        ol {
          color: violet;  
          font-style: italic;
          font-size: 23px;
        }
        header {
            margin: 18pt;
        }
    </style>
</head>
<body>
    <header>
        <h1 style="color:blue"><strong>Logistics Services Overview</strong></h1>
        <h2>Providing the best logistics solutions.</h2>
    </header>

    <section>
        <ol>Domestic Express</ol>
        <ol>International Shipping</ol>
        <ol>Warehouse Management</ol>
        <ol>Supply Chain Solutions</ol>
    </section>

    <img src="https://th.bing.com/th/id/OIP.0xPCmeFfuDYE-72oawoKSAHaEo?rs=1&pid=ImgDetMain" alt="Logistics">

    <p><a href="https://www.dhl.com/discover/en-global">Learn More</a></p>

</body>
</html>
EOF

}

write_config_file(){

cat << EOF > "/etc/nginx/conf.d/logistic.conf"
server {
        listen 80;
        listen [::]:80;

        root /srv/logistic.com/html;
        index UI.html UI.htm UI.nginx-debian.html;

        server_name logistic www.logistic.com;

        location / {
                try_files $uri $uri/ =404;
        }
EOF

}

change_permission(){

    sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' "/etc/selinux/config"

}


#--------------Main-------------------
chmod +x "$0"
switch_to_root
install_nginx nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo mkdir -p /srv/logistic.com/html/UI.html
sudo chown -R $USER:$USER /srv/logistic.com/html
write_html_file
sudo mkdir -p /etc/nginx/conf.d/logistic.conf
write_config_file
change_permission
sudo systemctl reload nginx
echo "Done configuration"

