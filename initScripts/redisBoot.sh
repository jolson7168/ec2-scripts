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

chown ec2-user:ec2-user /u01
mkdir /u01/download
chown ec2-user:ec2-user /u01/download
mkdir /u01/logs
chown ec2-user:ec2-user /u01/logs
#mkdir /u01/git
#chown ec2-user:ec2-user /u01/git


#install stuff
yum update --assumeyes
yum install binutils-2.* --assumeyes
yum install compat-libstdc++-33* --assumeyes
yum install elfutils-libelf-0.* --assumeyes
yum install elfutils-libelf-devel-* --assumeyes
yum install gcc-4.* --assumeyes
yum install gcc-c++-4.* --assumeyes
yum install glibc-2.* --assumeyes
yum install glibc-common-2.* --assumeyes
yum install glibc-devel-2.* --assumeyes
yum install glibc-headers-2.* --assumeyes
yum install ksh-2* --assumeyes
yum install libaio-0.* --assumeyes
yum install libaio-devel-0.* --assumeyes
yum install libgcc-4.* --assumeyes
yum install libstdc++-4.* --assumeyes
yum install libstdc++-devel-4.* --assumeyes
yum install mlocate --assumeyes
yum install readline-devel --assumeyes
yum install rlwrap --enablerepo=epel --assumeyes
#yum install git-core --assumeyes

wget -O /u01/download/redis-2.8.4.tar.gz http://download.redis.io/releases/redis-2.8.4.tar.gz
tar -xzf /u01/download/redis-2.8.4.tar.gz -C /u01/download
make -C /u01/download/redis-2.8.4

/u01/download/redis-2.8.4/src/redis-server &

#git clone https://github.com/jolson7168/pythonlibs.git /u01/git
#echo 'export PYTHONPATH=/u01/git/pythonlibs' >>/home/ec2-user/.bashrc
#chown ec2-user:ec2-user /home/ec2-user/.bashrc




