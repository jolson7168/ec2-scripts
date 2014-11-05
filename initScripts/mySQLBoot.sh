#!/bin/bash

#Init EBS vol for data
mkfs -t ext4 /dev/sdf
tune2fs -m0 /dev/sdf
mkdir /u01
mount /dev/sdf /u01
echo '/dev/sdf    /u01      auto    defaults,noatime 0  0' >>/etc/fstab

#create swap space
dd if=/dev/zero of=/home/swapfile bs=1024 count=2097152
mkswap /home/swapfile
swapon /home/swapfile
chown root:root /home/swapfile
chmod 0600 /home/swapfile
echo '/home/swapfile    swap      swap    defaults         0  0' >>/etc/fstab

sed -i "0,/enabled=1/s//enabled=0/" /etc/yum.repos.d/amzn-main.repo
sed -i "0,/enabled=1/s//enabled=0/" /etc/yum.repos.d/amzn-updates.repo

yum update --assumeyes
