#!/usr/bin/env bash

if [ -f /home/vagrant/.features/mysql ]
then
   echo "mysql already installed."
   exit 0
fi

touch /home/vagrant/.features/mysql
chown -Rf vagrant:vagrant /home/vagrant/.features

apt-get -y install mysql-server

systemctl enable mysql

# 配置mysql
#  - sudo mysql --user="root" -e "create database test;"
mysql --user="root" -e "CREATE USER 'jammy'@'%' IDENTIFIED WITH mysql_native_password BY 'secret';"
mysql --user="root" -e "GRANT ALL PRIVILEGES ON *.* TO 'jammy'@'%' WITH GRANT OPTION;"
mysql --user="root" -e "FLUSH PRIVILEGES;"
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl restart mysql