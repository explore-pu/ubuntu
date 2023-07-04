#!/usr/bin/env bash

if [ -f /home/vagrant/.features/nginx ]
then
   echo "nginx already installed."
   exit 0
fi

touch /home/vagrant/.features/nginx
chown -Rf vagrant:vagrant /home/vagrant/.features

apt-get -y install nginx

sed -i "s/user www-data;/user vagrant;" /etc/nginx/nginx.conf

systemctl enable nginx