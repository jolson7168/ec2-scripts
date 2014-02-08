#!/bin/bash

#create swap space
dd if=/dev/zero of=/home/swapfile bs=1024 count=2097152
mkswap /home/swapfile
swapon /home/swapfile
chown root:root /home/swapfile
chmod 0600 /home/swapfile
echo '/home/swapfile    swap      swap    defaults         0  0' >>/etc/fstab

#directories and whatnot
mkdir /home/ec2-user/downloads
chown ec2-user:ec2-user /home/ec2-user/downloads

#download stuff
wget -O /home/ec2-user/downloads/epel-release-6-8.noarch.rpm http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -Uvh /home/ec2-user/downloads/epel-release-6-8.noarch.rpm

#install stuff
yum update --assumeyes
yum install openvpn --assumeyes
cp /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn

