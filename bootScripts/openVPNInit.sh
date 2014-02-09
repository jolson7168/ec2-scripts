#!/bin/bash
#Amazon Linux AMI 2013.09.2 - ami-bba18dd2 (64 bit)

AMI=ami-81fe86e8
AWS_KEY=$1
AWS_SECRET_KEY=$2

ec2-run-instances $AMI --instance-count 1 --key "openvpn_rsa" --network-attachment :0:subnet-87ae8cc1::10.0.4.10:sg-e473bf81:: --aws-access-key $AWS_KEY --aws-secret-key $AWS_SECRET_KEY --instance-type t1.micro --availability-zone us-east-1d --instance-initiated-shutdown-behavior stop


