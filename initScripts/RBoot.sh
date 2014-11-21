#!/bin/bash
yum update --assumeyes
yum install R --assumeyes
yum install git --assumeyes
yum install xauth --assumeyes
yum install xclock --assumeyes
yum install httpd --assumeyes

chown apache:apache /var/www
echo "DocumentRoot /var/www" > /etc/httpd/conf.d/000-default.conf
echo "<Directory /var/www>" >> /etc/httpd/conf.d/000-default.conf
echo "       Options Indexes MultiViews" >> /etc/httpd/conf.d/000-default.conf
echo "       AllowOverride All" >> /etc/httpd/conf.d/000-default.conf
echo "       Order allow,deny" >> /etc/httpd/conf.d/000-default.conf
echo "       allow from all" >> /etc/httpd/conf.d/000-default.conf
echo "</Directory>" >> /etc/httpd/conf.d/000-default.conf
echo "" >> /etc/httpd/conf.d/000-default.conf
echo "Alias" /webdav /var/www >> /etc/httpd/conf.d/000-default.conf
echo "<Location /webdav>" >> /etc/httpd/conf.d/000-default.conf
echo "  DAV On" >> /etc/httpd/conf.d/000-default.conf
echo "</Location>" >> /etc/httpd/conf.d/000-default.conf 
service httpd start

mkdir /home/ec2-user/git
git clone https://github.com/jolson7168/weibull.git /home/ec2-user/git/weibull
chown -R ec2-user:ec2-user /home/ec2-user/git
Rscript /home/ec2-user/git/weibull/scripts/init.R >/home/ec2-user/git/weibull/scripts/rinit.out
#Start the service
Rscript /home/ec2-user/git/weibull/src/listener.R > /home/ec2-user/git/weibull/scripts/r.out &
