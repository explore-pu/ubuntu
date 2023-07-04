#!/usr/bin/env bash

listen_80="listen ${3:-80};"
listen_443="listen ${4:-443} ssl http2;"
server_name=".$1"
if [[ "${5}" != "false" ]]; then
    listen_80="listen ${3:-80} default_server;"
    server_name="$6"
fi

block="server {
    $listen_80
    $listen_443
    server_name $server_name;
    root \"$2\";

    index index.html index.htm;

    charset utf-8;
    client_max_body_size 100m;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$1-error.log error;

    sendfile off;

    ssl_certificate     /etc/ssl/certs/$1.crt;
    ssl_certificate_key /etc/ssl/certs/$1.key;
}
"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"
