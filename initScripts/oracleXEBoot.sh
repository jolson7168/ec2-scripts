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


#set hostname
rm /etc/sysconfig/network
echo NETWORKING=yes > /etc/sysconfig/network
echo HOSTNAME=ec2oracleEX.local >> /etc/sysconfig/network
echo NOZEROCONF=yes >> /etc/sysconfig/network
echo NETWORKING_IPV6=no >> /etc/sysconfig/network
echo IPV6INIT=no >> /etc/sysconfig/network
echo IPV6_ROUTER=no >> /etc/sysconfig/network
echo IPV6_AUTOCONF=no >> /etc/sysconfig/network
echo IPV6FORWARDING=no >> /etc/sysconfig/network
echo IPV6TO4INIT=no >> /etc/sysconfig/network
echo IPV6_CONTROL_RADVD=no >> /etc/sysconfig/network
rm /etc/hosts
echo 127.0.0.1 localhost localhost.localdomain ec2oracleEx ec2oracleEx.local > /etc/hosts

#Add oracle user
groupadd oinstall
groupadd dba
useradd -g oinstall -G dba,oinstall oracle
adduser oracle sudo
mkdir /home/oracle/.ssh
chown oracle:oinstall /home/oracle/.ssh
cp /home/ec2-user/.ssh/authorized_keys /home/oracle/.ssh/authorized_keys
chown oracle:oinstall /home/oracle/.ssh/authorized_keys

#Make some directories
chown oracle:oinstall /u01
mkdir /u01/download
chown oracle:oinstall /u01/download
mkdir /u01/git
chown oracle:oinstall /u01/git
mkdir /u01/logs
chown oracle:oinstall /u01/logs
mkdir /u01/oradata
chown oracle:oinstall /u01/oradata
mkdir /u01/oradata/xe
chown oracle:oinstall /u01/oradata/xe

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
yum install make-3.* --assumeyes
yum install sysstat-7.* --assumeyes
yum install unixODBC-2.* --assumeyes
yum install unixODBC-devel-2.* --assumeyes
yum install git-core --assumeyes
yum install mlocate --assumeyes

#Change /etc/sysctl.conf
echo '# Added by Oracle...' >>/etc/sysctl.conf
echo 'fs.suid_dumpable = 1' >>/etc/sysctl.conf
echo 'fs.aio-max-nr = 1048576' >>/etc/sysctl.conf
echo 'fs.file-max = 6815744' >>/etc/sysctl.conf
echo 'kernel.shmall = 2097152' >>/etc/sysctl.conf
echo 'kernel.shmmax = 536870912' >>/etc/sysctl.conf
echo 'kernel.shmmni = 4096' >>/etc/sysctl.conf
echo 'kernel.sem = 250 32000 100 128' >>/etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range = 9000 65500' >>/etc/sysctl.conf
echo 'net.core.rmem_default = 262144' >>/etc/sysctl.conf
echo 'net.core.rmem_max = 4194304' >>/etc/sysctl.conf
echo 'net.core.wmem_default = 262144' >>/etc/sysctl.conf
echo 'net.core.wmem_max = 1048586' >>/etc/sysctl.conf

#Change /etc/security/limits.conf
echo 'oracle          soft     nproc           2047' >> /etc/security/limits.conf
echo 'oracle          hard     nproc           16384' >> /etc/security/limits.conf
echo 'oracle          soft     nofile          1024' >> /etc/security/limits.conf
echo 'oracle          hard     nofile          65536' >> /etc/security/limits.conf
echo 'oracle          soft     stack           10240' >> /etc/security/limits.conf

/sbin/sysctl -p

#Load source onto machine
mkdir /u01/git/geocoder
chown oracle:oinstall /u01/git/geocoder
git clone https://github.com/jolson7168/geocoder.git /u01/git/geocoder
chown -R oracle:oinstall /u01/git/geocoder
mkdir /u01/git/oracle
chown oracle:oinstall /u01/git/oracle
git clone https://github.com/jolson7168/oracle.git /u01/git/oracle
chown -R oracle:oinstall /u01/git/oracle
chmod +x /u01/git/oracle/scripts/installXEinstall.sh

#Get some external data
wget -O /u01/download/allCountries.zip http://download.geonames.org/export/dump/allCountries.zip
unzip /u01/download/allCountries.zip -d /u01/download
chown oracle:oinstall /u01/download/allCountries.txt
