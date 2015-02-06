#!/bin/bash
#Amazon Linux AMI 2014.09.2 (PV) 

AMI=ami-8e682ce6
AWS_KEY=$1
AWS_SECRET_KEY=$2
SUBNET=$3
IP=$4
SECURITY=$5
ZONE=$6
BOOT_SCRIPT=$7

echo $IP
results=$(ec2-allocate-address -d vpc -O $AWS_KEY -W $AWS_SECRET_KEY)
ip_new=$(echo $results | cut -f2 -d' ')
echo $ip_new
alloc=$(echo $results | cut -f4 -d' ')
echo $alloc
if [[ ! $ip_new =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo 'Error : Getting a new IP address'
        echo $ip_new
        exit
fi
results2=$(ec2-run-instances $AMI --instance-count 1 --key "python_rsa" --network-attachment :0:$SUBNET::$IP:$SECURITY:: --aws-access-key $AWS_KEY --aws-secret-key $AWS_SECRET_KEY --instance-type t1.micro --user-data-file $BOOT_SCRIPT --availability-zone $ZONE  --instance-initiated-shutdown-behavior terminate)
instance=$(echo $results2 | cut -f5 -d' ')
echo $instance
sleep 30
results3=$(ec2-associate-address --private-ip-address $IP -i $instance -O $AWS_KEY -W $AWS_SECRET_KEY --allocation-id $alloc)
assoc=$(echo $results3 | cut -f4 -d' ')
echo $assoc

