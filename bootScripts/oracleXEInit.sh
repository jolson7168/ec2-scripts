#!/bin/bash
#Amazon Linux AMI 2013.09.2 - ami-bba18dd2 (64 bit)
#EBS volume /dev/sdf get blown away upon instance terminating

#Akoya credentials
AMI=ami-bba18dd2
AWS_KEY=$1
AWS_SECRET_KEY=$2

ec2-run-instances $AMI --instance-count 1 --key "oracleEX_rsa" --aws-access-key $AWS_KEY --aws-secret-key $AWS_SECRET_KEY --group "OracleEx" --instance-type t1.small --user-data-file ../initScripts/oracleXEBoot.sh --availability-zone us-east-1a --block-device-mapping  "/dev/sdf=:10" --instance-initiated-shutdown-behavior stop 
