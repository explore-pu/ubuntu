#!/usr/bin/env bash

if [ -f /home/vagrant/.features/php81 ]
then
   echo "php 8.1 already installed."
   exit 0
fi

touch /home/vagrant/.features/php81
chown -Rf vagrant:vagrant /home/vagrant/.features

apt-get -y install \
php8.1 \
php8.1-bcmath \
php8.1-bz2 \
php8.1-cgi \
php8.1-cli \
php8.1-common \
php8.1-curl \
php8.1-dba \
php8.1-dev \
php8.1-enchant \
php8.1-fpm \
php8.1-gd \
php8.1-gmp \
php8.1-igbinary \
php8.1-imap \
php8.1-intl \
php8.1-ldap \
php8.1-mbstring \
php8.1-memcached \
php8.1-msgpack \
php8.1-mysql \
php8.1-odbc \
php8.1-opcache \
php8.1-pgsql \
php8.1-phpdbg \
php8.1-pspell \
php8.1-readline \
php8.1-redis \
php8.1-snmp \
php8.1-soap \
php8.1-sqlite3 \
php8.1-sybase \
php8.1-tidy \
php8.1-xdebug \
php8.1-xml \
php8.1-xmlrpc \
php8.1-xsl \
php8.1-zip

#systemctl enable php8.1-fpm

# 修改php配置
sed -i "s/;date.timezone.*/date.timezone = PRC/" /etc/php/8.1/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = PRC/" /etc/php/8.1/fpm/php.ini
sed -i "s/user = www-data/user = vagrant/" /etc/php/8.1/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = vagrant/" /etc/php/8.1/fpm/pool.d/www.conf
sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/8.1/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/8.1/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/8.1/fpm/pool.d/www.conf

#systemctl restart php8.1-fpm
