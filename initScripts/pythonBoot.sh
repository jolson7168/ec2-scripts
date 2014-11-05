#!/bin/bash
yum update --assumeyes
yum install python-pip --assumeyes
yum install git --assumeyes
pip install flask 
mkdir /home/ec2-user/git
git clone https://github.com/jolson7168/CarbonCalculator.git /home/ec2-user/git/CarbonCalculator
chown -R ec2-user:ec2-user /home/ec2-user/git
