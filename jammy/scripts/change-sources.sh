#!/usr/bin/env bash

new_sources="$1"
old_sources="http://archive.ubuntu.com"
#old_sources="http://us.archive.ubuntu.com"
if [[ -f /home/vagrant/.features/sources ]]; then
    old_sources=$(cat /home/vagrant/.features/sources)
fi

if [[ "$old_sources" != "$new_sources" ]]; then
    touch /home/vagrant/.features/sources
    echo "$new_sources" > /home/vagrant/.features/sources
    chown -Rf vagrant:vagrant /home/vagrant/.features

    sudo find /etc/apt -name 'sources.list' | xargs perl -pi -e "s|$old_sources|$new_sources|g"

    sudo apt-get update
fi
