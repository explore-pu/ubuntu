#!/usr/bin/env bash

if [ -f /home/vagrant/.features/apache2 ]
then
   echo "apache2 already installed."
   exit 0
fi

touch /home/vagrant/.features/apache2
chown -Rf vagrant:vagrant /home/vagrant/.features

apt-get -y install apache2 libapache2-mod-php8.1

sed -i "s/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/" /etc/apache2/envvars
sed -i "s/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=vagrant/" /etc/apache2/envvars

a2enmod rewrite

a2enmod ssl

systemctl enable apache2
