#!/bin/bash
#Amazon Linux AMI 2013.09.2 - ami-bba18dd2 (64 bit)

AMI=ami-bba18dd2
AWS_KEY=$1
AWS_SECRET_KEY=$2
NUM_INSTANCES=$3

ec2-run-instances $AMI --instance-count $NUM_INSTANCES --key "featureGenerator_rsa" --network-attachment :0:subnet-67645421:::sg-3e71d35b:: --aws-access-key $AWS_KEY --aws-secret-key $AWS_SECRET_KEY --instance-type m1.small --user-data-file ../initScripts/featureGeneratorBoot.sh --availability-zone us-east-1a --instance-initiated-shutdown-behavior terminate 


