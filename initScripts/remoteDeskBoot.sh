#!/bin/bash

apt-get update
apt-get install vnc4server
apt-get install ubuntu-desktop
apt-get install gnome-session-fallback
#http://community.spiceworks.com/topic/277165-ubuntu-xrdp-vnc-d-key-shows-desktop
apt-get install compizconfig-settings-manager

mkdir /home/ubuntu/downloads
wget -O /home/ubuntu/downloads https://www.torproject.org/dist/torbrowser/3.5.2/tor-browser-linux64-3.5.2_en-US.tar.xz
tar -xvJf tor-browser-linux64-3.5.2_LANG.tar.xz -C /home/ubuntu/downloads
chown -R ubuntu:ubuntu /home/ubuntu


sed -i '0,/127.0.0.1 localhost/s//127.0.0.1 localhost ip-10-4-20-15/' /etc/hosts
