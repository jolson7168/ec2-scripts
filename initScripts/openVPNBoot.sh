#!/bin/bash

#directories and whatnot


#enable epl repo
sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/epel.repo

#install stuff
yum update --assumeyes
yum install openvpn --assumeyes
yum install easy-rsa --assumeyes
yum install mlocate --assumeyes

#begin openvpn configuration
cp /usr/share/doc/openvpn-*/sample/sample-config-files/server.conf /etc/openvpn

echo '# Added by bootscript...' >> /etc/openvpn/server.conf
echo 'push "redirect-gateway def1 bypass-dhcp"' >> /etc/openvpn/server.conf
echo 'push "dhcp-option DNS 8.8.8.8"' >> /etc/openvpn/server.conf
echo 'push "dhcp-option DNS 8.8.4.4"' >> /etc/openvpn/server.conf
echo 'user nobody' >> /etc/openvpn/server.conf
echo 'group nobody' >> /etc/openvpn/server.conf

#set up certificates
sed -i '0,/export KEY_PROVINCE="CA"/s//export KEY_PROVINCE="IL"/' /usr/share/easy-rsa/2.0/vars
sed -i '0,/export KEY_CITY="SanFrancisco"/s//export KEY_CITY="Chicago"/' /usr/share/easy-rsa/2.0/vars
sed -i '0,/export KEY_ORG="Fort-Funston"/s//export KEY_ORG="Orgname"/' /usr/share/easy-rsa/2.0/vars
sed -i '0,/export KEY_EMAIL=mail@host.domain/s//export KEY_ORG=admin@domain.org/' /usr/share/easy-rsa/2.0/vars
sed -i '0,/export KEY_EMAIL="mail@host.domain"/s//export KEY_ORG="admin@domain.org"/' /usr/share/easy-rsa/2.0/vars
source /usr/share/easy-rsa/2.0/vars
/usr/share/easy-rsa/2.0/clean-all
#interaction starting here
#/usr/share/easy-rsa/2.0/build-ca
#and here
#/usr/share/easy-rsa/2.0/build-key-server server
#/usr/share/easy-rsa/2.0/build-dh

#just pull the certs pre-generated from a repo?
#cp /usr/share/easy-rsa/2.0/keys/dh1024.pem /etc/openvpn
#cp /usr/share/easy-rsa/2.0/keys/ca.crt /etc/openvpn
#cp /usr/share/easy-rsa/2.0/keys/server.crt /etc/openvpn
#cp /usr/share/easy-rsa/2.0/keys/server.key /etc/openvpn

#enable routing
#iptables -t nat -A POSTROUTING -s 10.0.4.0/24 -o eth0 -j MASQUERADE
#service iptables save
#echo 'net.ipv4.ip_forward = 1' >>/etc/sysctl.conf
#sed -i '0,/net.ipv4.ip_forward = 0/s//net.ipv4.ip_forward = 1/' /etc/sysctl.conf
#sysctl -p
#service openvpn start
#chkconfig openvpn on
