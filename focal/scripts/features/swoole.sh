#!/usr/bin/env bash

if [ -f /home/vagrant/.features/swoole ]
then
   echo "swoole already installed."
   exit 0
fi

touch /home/vagrant/.features/swoole
chown -Rf vagrant:vagrant /home/vagrant/.features

# 安装swoole扩展
pecl channel-update pecl.php.net

pecl install -D 'enable-sockets="yes" enable-openssl="yes" enable-debug="yes" enable-debug-log="yes" enable-http2="no" enable-mysqlnd="yes" enable-swoole-json="no" enable-swoole-curl="no" enable-cares="no" enable-brotli="no"' swoole-4.8.13

# 修改swoole配置
echo "extension = swoole.so" > /etc/php/7.4/mods-available/swoole.ini

sed -i "s/extension=xsl/extension=xsl\nswoole.use_shortname='Off'/" /etc/php/7.4/cli/php.ini

# 启动swoole扩展
phpenmod swoole
#phpdismod swoole
