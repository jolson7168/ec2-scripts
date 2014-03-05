#!/bin/bash

mkdir /home/ec2-user/git
chown ec2-user:ec2-user /home/ec2-user/git

mkdir /home/ec2-user/git/misc
chown ec2-user:ec2-user /home/ec2-user/git/misc


#yum-config-manager --enable epel
#install stuff
yum update --assumeyes
yum install git-core --assumeyes
yum install tcl --assumeyes

git clone https://github.com/jolson7168/pythonlibs.git /home/ec2-user/git/pythonlibs
echo 'export PYTHONPATH=/home/ec2-user/git/pythonlibs' >>/home/ec2-user/.bashrc
chown ec2-user:ec2-user /home/ec2-user/.bashrc
git clone https://github.com/jolson7168/timeseries_redis.git /home/ec2-user/git/timeseries_redis
wget -O /home/ec2-user/git/misc/get-pip.py https://raw.github.com/pypa/pip/master/contrib/get-pip.py
python /home/ec2-user/git/misc/get-pip.py
pip install redis
export PYTHONPATH=/home/ec2-user/git/pythonlibs
chown -R ec2-user:ec2-user /home/ec2-user/git
export ip=`ifconfig | awk -F':' '/inet addr/&&!/127.0.0.1/{split($2,_," ");print _[1]}'`
export offset=`echo $ip|cut -d'.' -f4`
sed -i "0,/submitId=101/s//submitId=$offset/" /home/ec2-user/git/timeseries_redis/config/loadFeatureData.conf
(cd /home/ec2-user/git/timeseries_redis/scripts/ && ./loadData.sh&)
