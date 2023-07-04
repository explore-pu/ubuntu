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
mysql --user="root" -e "alter user 'root'@'localhost' identified with mysql_native_password by '';"
mysql --user="root" -e "create user 'focal'@'%' identified with mysql_native_password by 'secret';"
mysql --user="root" -e "grant all privileges on *.* to 'focal'@'%' with grant option;"
#mysql --user="root" -e "create database test;"
mysql --user="root" -e "flush privileges;"
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl restart mysql
