#!/bin/bash
#Amazon Linux AMI 2013.09.2 - ami-bba18dd2 (64 bit)

AMI=ami-bba18dd2
AWS_KEY=$1
AWS_SECRET_KEY=$2

ec2-run-instances $AMI --instance-count 1 --key "mySQL_rsa" --network-attachment :0:subnet-fb6b5a92::10.10.10.100:sg-cdc618a8:: --aws-access-key $AWS_KEY --aws-secret-key $AWS_SECRET_KEY --instance-type m1.small --user-data-file ../initScripts/mySQLBoot.sh --block-device-mapping  "/dev/sdf=:10" --availability-zone us-east-1b --instance-initiated-shutdown-behavior stop


