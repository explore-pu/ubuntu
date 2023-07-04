#!/usr/bin/env bash

if [ -f /home/vagrant/.features/nodejs ]
then
   echo "nodejs already installed."
   exit 0
fi

touch /home/vagrant/.features/nodejs
chown -Rf vagrant:vagrant /home/vagrant/.features

# 安装nodejs
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -

apt-get install nodejs -y

npm install pm2 -g