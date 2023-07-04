#!/usr/bin/env bash

if [ -f /home/vagrant/.features/swoole ]
then
   echo "swoole already installed."
   exit 0
fi

touch /home/vagrant/.features/swoole
chown -Rf vagrant:vagrant /home/vagrant/.features

# 安装swoole扩展, 请手动安装
sudo pecl channel-update pecl.php.net

sudo apt-get install libc-ares-dev libcurl4-openssl-dev

sudo pecl install swoole-4.8.13

#all yes
# 修改swoole配置
sudo su
echo "extension = swoole.so" > /etc/php/7.4/mods-available/swoole.ini
echo "swoole.use_shortname='Off'" >> /etc/php/7.4/cli/php.ini
# 启动swoole扩展
phpenmod swoole
#phpdismod swoole
