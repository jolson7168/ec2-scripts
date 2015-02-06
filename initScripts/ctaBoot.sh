#!/bin/bash
rm /etc/localtime 
ln -s /usr/share/zoneinfo/US/Central localtime
yum update --assumeyes
yum install python-pip --assumeyes
yum install git --assumeyes
mkdir /home/ec2-user/git
git clone https://github.com/jolson7168/ctaTracker.git /home/ec2-user/git/ctaTracker
pip install requests
pip install xmltodict
chown -R ec2-user:ec2-user /home/ec2-user/git

