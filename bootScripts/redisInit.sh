#!/bin/bash
#Amazon Linux AMI 2013.09.2 - ami-bba18dd2 (64 bit)
#EBS volume /dev/sdf get blown away upon instance terminating

AMI=ami-bba18dd2
AWS_KEY=$1
AWS_SECRET_KEY=$2
SUBNET=$3
IP=$4
SECURITY=$5
ZONE=$6
TYPE=$7


if [ "$TYPE" == "master" ] 
then
	ec2-run-instances $AMI --instance-count 1 --key "redis_rsa" --network-attachment :0:$SUBNET::$IP:$SECURITY:: --aws-access-key $AWS_KEY --aws-secret-key $AWS_SECRET_KEY --instance-type m1.small --user-data-file ../initScripts/redisBootMaster.sh --availability-zone $ZONE --block-device-mapping  "/dev/sdf=:10" --instance-initiated-shutdown-behavior terminate
else
	ec2-run-instances $AMI --instance-count 1 --key "redis_rsa" --network-attachment :0:$SUBNET::$IP:$SECURITY:: --aws-access-key $AWS_KEY --aws-secret-key $AWS_SECRET_KEY --instance-type m1.small --user-data-file ../initScripts/redisBootSlave.sh --availability-zone $ZONE --block-device-mapping  "/dev/sdf=:10" --instance-initiated-shutdown-behavior terminate
 fi
