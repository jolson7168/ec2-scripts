#!/bin/bash

#create swap space
dd if=/dev/zero of=/home/swapfile bs=1024 count=2097152
mkswap /home/swapfile
swapon /home/swapfile
chown root:root /home/swapfile
chmod 0600 /home/swapfile
echo '/home/swapfile    swap      swap    defaults         0  0' >>/etc/fstab
#install stuff
yum update --assumeyes
yum install mlocate --assumeyes
yum install readline-devel --assumeyes
yum install rlwrap --enablerepo=epel --assumeyes
yum install http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm --assumeyes
yum install postgresql93-server --assumeyes
yum install postgresql93-contrib --assumeyes
yum install postgresql93-client --assumeyes

service iptables stop
chkconfig postgresql-9.3 on 
service postgresql-9.3 initdb

echo 'host    all             test            10.0.0.0/16             md5' >>/var/lib/pgsql/9.3/data/pg_hba.conf
echo 'host    all	      postgres        10.0.0.0/16         trust' >>/var/lib/pgsql/9.3/data/pg_hba.conf
echo 'host    replication     replication     10.0.241.55/32         trust' >>/var/lib/pgsql/9.3/data/pg_hba.conf
#host  replication  replication  10.0.241.55/32  trust
echo "listen_addresses = '*'" >>/var/lib/pgsql/9.3/data/postgresql.conf
echo 'wal_level = hot_standby' >> /var/lib/pgsql/9.3/data/postgresql.conf
echo 'max_wal_senders = 5' >> /var/lib/pgsql/9.3/data/postgresql.conf
echo 'wal_keep_segments = 32' >> /var/lib/pgsql/9.3/data/postgresql.conf
echo 'archive_mode = on' >> /var/lib/pgsql/9.3/data/postgresql.conf
echo "archive_command = 'rsync -W -e \"ssh -o StrictHostKeyChecking=no\" -a %p postgres@10.0.241.55:/var/lib/pgsql/9.3/archive/%f'" >> /var/lib/pgsql/9.3/data/postgresql.conf
echo 'archive_timeout = 10' >> /var/lib/pgsql/9.3/data/postgresql.conf

mkdir /var/lib/pgsql/9.3/archive
chown postgres:postgres /var/lib/pgsql/9.3/archive

service postgresql-9.3 start

#as OS user postgres 
echo "CREATE role test LOGIN PASSWORD 'test' SUPERUSER;" > /var/lib/pgsql/start.sql
echo "CREATE role replication LOGIN PASSWORD 'replication' SUPERUSER;" >> /var/lib/pgsql/start.sql
echo 'CREATE DATABASE TEST;' >> /var/lib/pgsql/start.sql
chown postgres:postgres /var/lib/pgsql/start.sql
runuser -l postgres -c'/usr/bin/psql -f /var/lib/pgsql/start.sql'

mkdir /var/lib/pgsql/.ssh
chown postgres:postgres /var/lib/pgsql/.ssh
echo '-----BEGIN RSA PRIVATE KEY-----' > /var/lib/pgsql/.ssh/id_rsa
echo 'MIIEowIBAAKCAQEAsS3P6PWPBOIKZzxFmKiD/1CLfCDIwbuLp/MVs3MGN2QtY55l' >> /var/lib/pgsql/.ssh/id_rsa
echo 'MhkqPLt+EYnQ4wAdG16ByPKAji6xCistaWcKjpdefoFvhLdXgdj06zjtI0CD8I2J' >> /var/lib/pgsql/.ssh/id_rsa
echo 'yvM5pJurZ79dGIpL5J1KZrvDS8nYseupFr23qzlOaajvg8HPYHanseYYBnZHgy/H' >> /var/lib/pgsql/.ssh/id_rsa
echo 'Dy1ExynF2kQtsNXvtKzSlnsR967n7BgcbkGDSWrYJJJXHG68esXPtcgvFA1OEJbY' >> /var/lib/pgsql/.ssh/id_rsa
echo 'iTrEBSozcaQpKgNYH78ocZ5qU7BXLUdlsvMfzOGvx2FnFpZr4r6chSdWLBZiqPtv' >> /var/lib/pgsql/.ssh/id_rsa
echo '5ePYU2a9t6HZj6Meer2NfxNQfItUDFIie/L94wIDAQABAoIBAH7nnlxwzgCkWuk4' >> /var/lib/pgsql/.ssh/id_rsa
echo 'rWy7ftf3fADrhn/k8hHYtflzcMdp9Gy+/iKVDcC0Vob/XGPLKA37ciBZOaUdYmcz' >> /var/lib/pgsql/.ssh/id_rsa
echo 'J/KwAErDtsYLtbGslHwHxt1YR9oREq/Q4RpBfk8dxPaphWfXXqaf1rOg1zBIofJG' >> /var/lib/pgsql/.ssh/id_rsa
echo 'JjWIq65zfGuHug54Wi3wrwpoEVtGWHU8bWIIzwLcXNtOMUM24Mls1hJLeDEsrz4T' >> /var/lib/pgsql/.ssh/id_rsa
echo 'xIGl38zuVrbA7Y2OdmB7VJSVkSuntE3GsMZHynJrDmi6G54fvINSekFxsmWthbJW' >> /var/lib/pgsql/.ssh/id_rsa
echo 'uAtTP5zigY4kcFTekvRX3idThsgriFrVeeRqN1BzHqFYcWBARtPG8p92EO8iyX6F' >> /var/lib/pgsql/.ssh/id_rsa
echo 's2ZLbAECgYEA6UcoHNINfcINFNIjkdsrftBPm4q5LzcaZVOqtrVuNmUYyqKz73Ga' >> /var/lib/pgsql/.ssh/id_rsa
echo 'Qa17eeBmFD+3I81S4ciLA/9quPjFZp0BJZN1rlheUVt1Unc9dn67hkvR9bQCvSuo' >> /var/lib/pgsql/.ssh/id_rsa
echo 'gM2d6bxRbngSXSfURBy2aoa9P/hUNvJM8VKNWOusnHk6ZoBcorw5E+MCgYEAwm/Q' >> /var/lib/pgsql/.ssh/id_rsa
echo 'IewSJJ4NZUQUQjDRQS/xY1stDYhdUR8EnPROa2wozaIzMlrtrQqRuSlR0k+clp5p' >> /var/lib/pgsql/.ssh/id_rsa
echo 'lexXBqxkfZZdvEtRQAo+oyuoHxTGgSXbt9EAsUw3AdNrlhjxPviZwueKmFDk0Xrn' >> /var/lib/pgsql/.ssh/id_rsa
echo 'b4ggLCwIgRwRzJqcl/M9cHA139v2zYbQq8EmjgECgYBKiR3b95Gv+OzNFkefNvQy' >> /var/lib/pgsql/.ssh/id_rsa
echo '1MRa4nxBBc49Sfpl3pqUbsD5Hft4KkgrbA7j5js3hRQzMEunMLiaUmX7LCGGo+vV' >> /var/lib/pgsql/.ssh/id_rsa
echo '4cPcLQgV3q8h5k+RKPUp99fiNd4aK3TvksM+B5nNPjg/45YDHVl7uAmIAwSFee3z' >> /var/lib/pgsql/.ssh/id_rsa
echo 'vXjETKkeZe2vCpyOsq1aGQKBgQCmUrlq2yLl+eGhl2vw9wt5RMarZCoU4mpY4zyx' >> /var/lib/pgsql/.ssh/id_rsa
echo '+nY+hAYfaTl8QLYBiQIAryzTx9A+M4JEgigriDpqB79lO9RkAJ92OvkUpVPs0/Kw' >> /var/lib/pgsql/.ssh/id_rsa
echo 'ufNqtrRzNmRYwDtVz5jQVfqDsucZnpXtHTfQMVaRAu7i4/tCLAuJbCNZvDLRuxoz' >> /var/lib/pgsql/.ssh/id_rsa
echo 'YgVWAQKBgCD2RfJj3BFUHdQxaGjjL/qbdE5c1eubthIF4S3FHntekM3mRdyXK9/c' >> /var/lib/pgsql/.ssh/id_rsa
echo 'aJ9NGmSND+xShQac0xy1jN5pevERBR84YbKqPabwQDxbwJbi+T264Cc9+YmGiZaV' >> /var/lib/pgsql/.ssh/id_rsa
echo '7sba5G4cYkOt2frSIyJxv1zUx9fYA94tZd3QH97BMnNWFOtEuMCN' >> /var/lib/pgsql/.ssh/id_rsa
echo '-----END RSA PRIVATE KEY-----' >> /var/lib/pgsql/.ssh/id_rsa
chown postgres:postgres /var/lib/pgsql/.ssh/id_rsa
chmod 600 /var/lib/pgsql/.ssh/id_rsa
echo "StrictHostKeyChecking no" > /var/lib/pgsql/.ssh/.config
chown postgres:postgres /var/lib/pgsql/.ssh/.config
