#!/bin/bash
#Amazon Linux AMI 2013.09.2 - ami-bba18dd2 (64 bit)
#EBS volume /dev/sdf get blown away upon instance terminating

AMI=ami-bba18dd2
AWS_KEY=$1
AWS_SECRET_KEY=$2

ec2-run-instances $AMI --instance-count 1 --key "redis_rsa" --network-attachment :0:subnet-d8a0d4f0::10.0.10.55:sg-cb6877a9:: --aws-access-key $AWS_KEY --aws-secret-key $AWS_SECRET_KEY --instance-type m1.small --user-data-file ../initScripts/redisBoot.sh --availability-zone us-east-1b --block-device-mapping  "/dev/sdf=:10" --instance-initiated-shutdown-behavior terminate 


