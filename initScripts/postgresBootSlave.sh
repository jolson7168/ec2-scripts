#!/bin/bash

#create swap space
dd if=/dev/zero of=/home/swapfile bs=1024 count=2097152
mkswap /home/swapfile
swapon /home/swapfile
chown root:root /home/swapfile
chmod 0600 /home/swapfile
echo '/home/swapfile    swap      swap    defaults         0  0' >>/etc/fstab

#install stuff
#yum update --assumeyes
yum install mlocate --assumeyes
yum install readline-devel --assumeyes
yum install rlwrap --enablerepo=epel --assumeyes
yum install http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm --assumeyes
yum install postgresql93-server --assumeyes
yum install postgresql93-contrib --assumeyes
yum install postgresql93-client --assumeyes

chkconfig postgresql-9.3 on 
service postgresql-9.3 initdb

echo 'host    all             test            10.0.0.0/16             md5' >>/var/lib/pgsql/9.3/data/pg_hba.conf
echo 'host    all	      postgres        10.0.0.0/16         trust' >>/var/lib/pgsql/9.3/data/pg_hba.conf
echo 'host    replication     replication     10.0.141.55/32         trust' >>/var/lib/pgsql/9.3/data/pg_hba.conf

echo "listen_addresses = '*'" >>/var/lib/pgsql/9.3/data/postgresql.conf
echo 'hot_standby = on' >> /var/lib/pgsql/9.3/data/postgresql.conf
#fix this?
#echo "restore_command = 'cp /var/lib/pgsql/archive/%f %p'" >/var/lib/pgsql/9.3/data/recovery.conf
#echo "standby_mode = 'on'" >>/var/lib/pgsql/9.3/data/recovery.conf
#echo "primary_conninfo = 'host=10.0.141.55 port=5432 user=postgres password=postgres'">>/var/lib/pgsql/9.3/data/recovery.conf
#chown postgres:postgres /var/lib/pgsql/9.3/data/recovery.conf

cp /var/lib/pgsql/9.3/data/pg_hba.conf /tmp
cp /var/lib/pgsql/9.3/data/postgresql.conf /tmp

mkdir /var/lib/pgsql/9.3/archive
chmod 777 /var/lib/pgsql/9.3/archive


echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxLc/o9Y8E4gpnPEWYqIP/UIt8IMjBu4un8xWzcwY3ZC1jnmUyGSo8u34RidDjAB0bXoHI8oCOLrEKKy1pZwqOl15+gW+Et1eB2PTrOO0jQIPwjYnK8zmkm6tnv10YikvknUpmu8NLydix66kWvberOU5pqO+Dwc9gdqex5hgGdkeDL8cPLUTHKcXaRC2w1e+0rNKWexH3rufsGBxuQYNJatgkklccbrx6xc+1yC8UDU4QltiJOsQFKjNxpCkqA1gfvyhxnmpTsFctR2Wy8x/M4a/HYWcWlmvivpyFJ1YsFmKo+2/l49hTZr23odmPox56vY1/E1B8i1QMUiJ78v3j postgres_rsa" >> /root/.ssh/authorized_keys
mkdir /var/lib/pgsql/.ssh
chown postgres:postgres /var/lib/pgsql/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxLc/o9Y8E4gpnPEWYqIP/UIt8IMjBu4un8xWzcwY3ZC1jnmUyGSo8u34RidDjAB0bXoHI8oCOLrEKKy1pZwqOl15+gW+Et1eB2PTrOO0jQIPwjYnK8zmkm6tnv10YikvknUpmu8NLydix66kWvberOU5pqO+Dwc9gdqex5hgGdkeDL8cPLUTHKcXaRC2w1e+0rNKWexH3rufsGBxuQYNJatgkklccbrx6xc+1yC8UDU4QltiJOsQFKjNxpCkqA1gfvyhxnmpTsFctR2Wy8x/M4a/HYWcWlmvivpyFJ1YsFmKo+2/l49hTZr23odmPox56vY1/E1B8i1QMUiJ78v3j postgres_rsa" > /var/lib/pgsql/.ssh/authorized_keys
chown postgres:postgres /var/lib/pgsql/.ssh/authorized_keys
chmod 600 /var/lib/pgsql/.ssh/authorized_keys
echo "StrictHostKeyChecking no" > /var/lib/pgsql/.ssh/.config
chown postgres:postgres /var/lib/pgsql/.ssh/.config

rm -rf /var/lib/pgsql/9.3/data
mkdir /var/lib/pgsql/9.3/data
chown postgres:postgres /var/lib/pgsql/9.3/data
chmod 700 /var/lib/pgsql/9.3/data
echo "runuser -l postgres -c'pg_basebackup -R -U replication -D /var/lib/pgsql/9.3/data --host=10.0.141.55 --port=5432'" >/root/start.sh
echo "chown -R postgres:postgres /var/lib/pgsql/9.3/data" >>/root/start.sh
echo "cp /tmp/pg_hba.conf /var/lib/pgsql/9.3/data" >>/root/start.sh
echo "cp /tmp/postgresql.conf /var/lib/pgsql/9.3/data" >>/root/start.sh
echo "chown postgres:postgres /var/lib/pgsql/9.3/data/pg_hba.conf" >>/root/start.sh
echo "chown postgres:postgres /var/lib/pgsql/9.3/data/postgresql.conf" >>/root/start.sh
echo "chown -R postgres:postgres /var/lib/pgsql/9.3/archive" >>/root/start.sh
echo "service postgresql-9.3 start" >>/root/start.sh
chmod +x /root/start.sh
/root/start.sh&
