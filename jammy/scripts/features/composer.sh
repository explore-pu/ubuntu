#!/usr/bin/env bash

if [ -f /home/vagrant/.features/composer ]
then
   echo "composer already installed."
   exit 0
fi

touch /home/vagrant/.features/composer
chown -Rf vagrant:vagrant /home/vagrant/.features

# 安装composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
chmod a+x /usr/local/bin/composer
php -r "unlink('composer-setup.php');"
#composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/