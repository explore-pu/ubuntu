#!/usr/bin/env bash

ServerName="$1"
if [[ "${5}" != "false" ]]; then
    ServerName="$6"
fi

block="<VirtualHost *:$3>
    ServerAdmin webmaster@localhost
    ServerName $ServerName
    ServerAlias www.$1
    DocumentRoot "$2"

    <Directory "$2">
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$1-error.log
    CustomLog \${APACHE_LOG_DIR}/$1-access.log combined

    #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"

if [[ "${5}" == "false" ]]; then
  echo "$block" > "/etc/apache2/sites-available/$1.conf"
  ln -fs "/etc/apache2/sites-available/$1.conf" "/etc/apache2/sites-enabled/$1.conf"
else
  echo "$block" >"/etc/apache2/sites-available/000-default.conf"
  ln -fs "/etc/apache2/sites-available/000-default.conf" "/etc/apache2/sites-enabled/000-default.conf"
fi

blockssl="<IfModule mod_ssl.c>
    <VirtualHost *:$4>
        ServerAdmin webmaster@localhost
        ServerName $ServerName
        ServerAlias www.$1
        DocumentRoot "$2"

        <Directory "$2">
            AllowOverride All
            Require all granted
        </Directory>

        #LogLevel info ssl:warn

        ErrorLog \${APACHE_LOG_DIR}/$1-error.log
        CustomLog \${APACHE_LOG_DIR}/$1-access.log combined

        #Include conf-available/serve-cgi-bin.conf

        #   SSL Engine Switch:
        #   Enable/Disable SSL for this virtual host.
        SSLEngine on

        #SSLCertificateFile  /etc/ssl/certs/ssl-cert-snakeoil.pem
        #SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

        SSLCertificateFile      /etc/ssl/certs/$1.crt
        SSLCertificateKeyFile   /etc/ssl/certs/$1.key
    </VirtualHost>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"

if [[ "${11}" == "false" ]]; then
  echo "$blockssl" > "/etc/apache2/sites-available/$1-ssl.conf"
  ln -fs "/etc/apache2/sites-available/$1-ssl.conf" "/etc/apache2/sites-enabled/$1-ssl.conf"
else
  echo "$blockssl" >"/etc/apache2/sites-available/default-ssl.conf"
  ln -fs "/etc/apache2/sites-available/000-default-ssl.conf" "/etc/apache2/sites-enabled/default-ssl.conf"
fi

service apache2 reload
