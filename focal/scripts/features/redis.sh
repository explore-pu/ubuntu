#!/usr/bin/env bash

if [ -f /home/vagrant/.features/redis ]
then
   echo "redis already installed."
   exit 0
fi

touch /home/vagrant/.features/redis
chown -Rf vagrant:vagrant /home/vagrant/.features

apt-get -y install redis-server

systemctl enable redis-server

# 配置redis
sed -i "s/bind 127.0.0.1 ::1/bind 0.0.0.0/" /etc/redis/redis.conf

systemctl restart redis-server