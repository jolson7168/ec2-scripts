#!/bin/bash

mkdir /home/ec2-user/git
chown ec2-user:ec2-user /home/ec2-user/git

#install stuff
yum update --assumeyes
yum install git-core --assumeyes


git clone https://github.com/jolson7168/pythonlibs.git /home/ec2-user/git
echo 'export PYTHONPATH=/home/ec2-user/git/pythonlibs' >>/home/ec2-user/.bashrc
chown ec2-user:ec2-user /home/ec2-user/.bashrc

git clone https://github.com/jolson7168/timeseries_redis.git /home/ec2-user/git



