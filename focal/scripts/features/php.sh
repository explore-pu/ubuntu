#!/usr/bin/env bash

if [ -f /home/vagrant/.features/php74 ]
then
   echo "php 7.4 already installed."
   exit 0
fi

touch /home/vagrant/.features/php74
chown -Rf vagrant:vagrant /home/vagrant/.features

apt-get -y install \
libapache2-mod-php7.4 \
php7.4 \
php7.4-bcmath \
php7.4-bz2 \
php7.4-cgi \
php7.4-cli \
php7.4-common \
php7.4-curl \
php7.4-dba \
php7.4-dev \
php7.4-enchant \
php7.4-fpm \
php7.4-gd \
php7.4-gmp \
php7.4-igbinary \
php7.4-imap \
php7.4-intl \
php7.4-ldap \
php7.4-mbstring \
php7.4-memcached \
php7.4-msgpack \
php7.4-mysql \
php7.4-odbc \
php7.4-opcache \
php7.4-pgsql \
php7.4-phpdbg \
php7.4-pspell \
php7.4-readline \
php7.4-redis \
php7.4-snmp \
php7.4-soap \
php7.4-sqlite3 \
php7.4-sybase \
php7.4-tidy \
php7.4-xdebug \
php7.4-xml \
php7.4-xmlrpc \
php7.4-xsl \
php7.4-zip

#systemctl enable php7.4-fpm

# 修改php配置
sed -i "s/;date.timezone.*/date.timezone = PRC/" /etc/php/7.4/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = PRC/" /etc/php/7.4/fpm/php.ini
sed -i "s/user = www-data/user = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.4/fpm/pool.d/www.conf

#systemctl restart php7.4-fpm
