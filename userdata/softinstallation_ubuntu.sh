#!/bin/bash

echo "----------update and upgrade packages----------"
sudo apt update
sudo apt upgrade -y
sudo apt --fix-broken install -y
sudo apt -y install curl
sudo apt -y install wget
sudo apt install libfuse2 -y
sudo apt install git -y
sudo apt install ssh -y
echo ""
echo ""
echo ""
echo ""
echo ""

echo "----------Google Chrome----------"
sudo apt --fix-broken install -y
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb


echo ""
echo ""
echo ""
echo ""
echo ""

echo "----------Ubuntu control settinge----------"
sudo apt --fix-broken install -y
sudo apt install gnome-control-center

echo ""
echo ""
echo ""
echo ""
echo ""

echo "----------Desklog----------"
sudo apt --fix-broken install -y
sudo wget https://desklogclient.s3.ap-south-1.amazonaws.com/clients/Desklog-Client-2.09.deb
sudo dpkg -i Desklog-Client-2.09.deb

echo ""
echo ""
echo ""
echo ""
echo ""

echo "----------AppImage installation----------"
sudo apt --fix-broken install -y
sudo add-apt-repository ppa:appimagelauncher-team/stable -y
sudo apt-get update -y
sudo apt-get install appimagelauncher -y

echo ""
echo ""
echo ""
echo ""
echo ""

echo "----------Apache installation----------"
sudo apt --fix-broken install -y
sudo apt update
sudo apt install apache2 -y
sudo ufw app list
sudo ufw allow 'Apache'
sudo ufw status
sudo systemctl start apache2

sudo chmod -R 777 /var/www/html
sudo chown -R www-data:www-data /var/www/html

echo ""
echo ""
echo ""
echo ""
echo ""

echo "----------MySQL installation----------"

sudo apt update -y
sudo apt install mysql-server -y
sudo systemctl start mysql.service

echo ""
echo ""
echo ""
echo ""
echo ""

echo "----------PHP 8.1 installation ----------"

sudo apt --fix-broken install -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
sudo apt install -y php7.2 php7.2-common php7.2-cli php7.2-fpm php7.2-mysql php7.2-xml php7.2-curl php7.2-gd php7.2-imagick php7.2-mbstring php7.2-zip php7.2-bcmath php7.2-intl php7.2-ldap php7.2-opcache php7.2-readline php7.2
sudo apt install -y php8.1 php8.1-common php8.1-cli php8.1-fpm php8.1-mysql php8.1-xml php8.1-curl php8.1-gd php8.1-imagick php8.1-mbstring php8.1-zip php8.1-bcmath php8.1-intl php8.1-ldap php8.1-opcache php8.1-readline php8.1
sudo apt install -y php8.2 php8.2-common php8.2-cli php8.2-fpm php8.2-mysql php8.2-xml php8.2-curl php8.2-gd php8.2-imagick php8.2-mbstring php8.2-zip php8.2-bcmath php8.2-intl php8.2-ldap php8.2-opcache php8.2-readline php8.2
sudo apt install -y php8.3 php8.3-common php8.3-cli php8.3-fpm php8.3-mysql php8.3-xml php8.3-curl php8.3-gd php8.3-imagick php8.3-mbstring php8.3-zip php8.3-bcmath php8.3-intl php8.3-ldap php8.3-opcache php8.3-readline php8.3
sudo apt install -y php8.4 php8.4-common php8.4-cli php8.4-fpm php8.4-mysql php8.4-xml php8.4-curl php8.4-gd php8.4-imagick php8.4-mbstring php8.4-zip php8.4-bcmath php8.4-intl php8.4-ldap php8.4-opcache php8.4-readline php8.4


sudo apt install libapache2-mod-php -y

echo ""
echo ""
echo ""
echo ""
echo ""

echo "--------- Install Nodejs and NPM using NVM (Node Version Manager) ---------"
sudo apt --fix-broken install -y
sudo apt install nodejs npm -y
sudo apt -y install curl
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc


echo ""
echo ""
echo ""
echo ""
echo ""

echo "----------VS code insatllation----------"
sudo apt --fix-broken install -y
sudo apt update
sudo apt install -y curl wget apt-transport-https
sudo curl -o vscode.deb -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo dpkg -i vscode.deb
sudo apt install -f

echo ""
echo ""
echo ""
echo ""

echo "----------Docker installation----------"

sudo apt --fix-broken install -y

# Add Docker's official GPG key:
sudo apt -y install curl
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

#Docker  Compose
sudo apt update
sudo apt install docker-compose -y

#post installation docker
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
echo ""
echo ""
echo ""
echo ""
echo ""
echo "----------Installation Verify----------"
echo ""
echo "PHP version:"
php -v
echo ""
echo "Docker version:"
docker --version
echo ""
echo "Node.js version:"
node -v
echo ""
echo "NPM version:"
npm -v
echo ""
echo "MySQL version:"
mysql --version
echo ""
echo "Apache version:"
apache2 -v
echo ""
echo "Docker Compose version:"
docker-compose --version
