#!/bin/bash
yum update --assumeyes
yum install R --assumeyes
yum install git --assumeyes
yum install xauth --assumeyes
yum install xclock --assumeyes
mkdir /home/ec2-user/git
git clone https://github.com/jolson7168/weibull.git /home/ec2-user/git/weibull
chown -R ec2-user:ec2-user /home/ec2-user/git
Rscript /home/ec2-user/git/weibull/scripts/init.R >/home/ec2-user/git/weibull/scripts/rinit.out
#Start the service
Rscript /home/ec2-user/git/weibull/src/listener.R > /home/ec2-user/git/weibull/scripts/r.out &
