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

echo '#Added by bootscript' >>/etc/sysctl.conf
echo 'vm.overcommit_memory = 1' >>/etc/sysctl.conf
/sbin/sysctl -p

#install stuff
yum update --assumeyes
yum groupinstall 'Development Tools' --assumeyes
yum install tcl --assumeyes
yum install rlwrap --enablerepo=epel --assumeyes

#directories
mkdir /u01/download
mkdir /u01/logs
mkdir /u01/scripts
mkdir /u01/config
mkdir /u01/git
mkdir /u01/upload


#config
wget -O /u01/download/3.0.0-rc4.tar.gz https://github.com/antirez/redis/archive/3.0.0-rc4.tar.gz
tar xvzf /u01/download/3.0.0-rc4.tar.gz -C /u01
make -C /u01/redis-3.0.0-rc4 >>/u01/logs/make.txt
make test -C /u01/redis-3.0.0-rc4 >>/u01/logs/test.txt

cp /u01/redis-3.0.0-rc4/redis.conf /u01/config

echo '/u01/redis-3.0.0-rc4/src/redis-server /u01/config/redis.conf' >>/u01/scripts/start.sh
chmod +x /u01/scripts/start.sh

wget -O /u01/config/dump.zip https://s3.amazonaws.com/kpit-test01/dump.zip
unzip /u01/config/dump.zip -d /u01/config


#Redis config
sed -i 's/daemonize no/daemonize yes/g' /u01/config/redis.conf
sed -i 's,dir ./,dir /u01/config,g' /u01/config/redis.conf
sed -i 's,logfile "",logfile /u01/logs/redislog.txt,g' /u01/config/redis.conf


chown -R ec2-user:ec2-user /u01

#Start Redis here
/u01/scripts/start.sh &

