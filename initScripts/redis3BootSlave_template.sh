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
yum install git --assumeyes
yum install python-pip --assumeyes
yum install gcc --assumeyes
yum install python-dev --assumeyes
yum install python-setuptools --assumeyes 
yum install libffi-dev --assumeyes

pip install gcs-oauth2-boto-plugin==1.8
pip install boto

#directories
mkdir /u01/download
mkdir /u01/logs
mkdir /u01/scripts
mkdir /u01/config
mkdir /u01/git

#config
wget -O /u01/download/3.0.0-rc4.tar.gz https://github.com/antirez/redis/archive/3.0.0-rc4.tar.gz
tar xvzf /u01/download/3.0.0-rc4.tar.gz -C /u01
make -C /u01/redis-3.0.0-rc4 >>/u01/logs/make.txt
make test -C /u01/redis-3.0.0-rc4 >>/u01/logs/test.txt

git clone https://github.com/jolson7168/redis.git /u01/git/redis
git clone https://github.com/jolson7168/pythonlibs.git /u01/git/python


cp /u01/redis-3.0.0-rc4/redis.conf /u01/config

echo '/u01/redis-3.0.0-rc4/src/redis-server /u01/config/redis.conf' >>/u01/scripts/start.sh
chmod +x /u01/scripts/start.sh

#Redis config
sed -i 's/daemonize no/daemonize yes/g' /u01/config/redis.conf
sed -i 's,dir ./,dir /u01/config,g' /u01/config/redis.conf
sed -i 's,logfile "",logfile /u01/logs/redislog.txt,g' /u01/config/redis.conf
sed -i 's/appendonly no/appendonly yes/g' /u01/config/redis.conf
echo 'slaveof [Redis Master] 6379' >>/u01/config/redis.conf

#archiver config
cp /u01/git/redis/archiver/config/archiver_template.conf /u01/git/redis/archiver/config/archiver.conf
sed -i "s,<Path to Redis AOF>,'/u01/config/appendonly.aof',g" /u01/git/redis/archiver/config/archiver.conf
sed -i "s,<Path to where you want the log file to go>,'/u01/logs/archiver.log',g" /u01/git/redis/archiver/config/archiver.conf
sed -i "s/<ACCESS_KEY>/'[Access key]'/g" /u01/git/redis/archiver/config/archiver.conf
sed -i "s/<ACCESS_SECRET_KEY>/'[Secret Access Key]'/g" /u01/git/redis/archiver/config/archiver.conf
sed -i "s/<EC2 Bucket>/'[Cloud Store Bucket]'/g" /u01/git/redis/archiver/config/archiver.conf
cp /u01/git/redis/archiver/scripts/archive_template.sh /u01/git/redis/archiver/scripts/archive.sh
sed -i "s,<PYTHON PATH HERE>,/u01/git/python,g" /u01/git/redis/archiver/scripts/archive.sh
chmod +x /u01/git/redis/archiver/scripts/archive.sh
chown -R ec2-user:ec2-user /u01


#start redis here
#on .aof size != 0 
	#start archiver in once only mode here
	#start archiver in tail mode here

