#!/bin/bash
#Amazon Linux AMI 2013.09.2 - ami-bba18dd2 (64 bit)

AMI=ami-d7c6ffbe
AWS_KEY=$1
AWS_SECRET_KEY=$2

ec2-run-instances $AMI --instance-count 1 --key "remotedesk_rsa" --network-attachment :0:subnet-2e486468::10.4.20.15:sg-0774ba62:: --aws-access-key $AWS_KEY --aws-secret-key $AWS_SECRET_KEY --instance-type t1.micro --availability-zone us-east-1d --user-data-file ../initScripts/remoteDeskBoot.sh --instance-initiated-shutdown-behavior stop


