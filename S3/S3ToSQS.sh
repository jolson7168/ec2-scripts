#!/bin/bash

# S3toSQS
# -------
# This script reads the contents of a given S3 bucket, and dumps the paths & filenames of all the keys in that bucket into an SQS queue
#
# NOTES: for this script, the S3 bucket must be public, the SQS queue can be private.
# This script will only go one level deep on the bucket
# The queue items will be of the form <s3 bucket>:<key> 

#Arguments
# S3 Arguments
# ------------
# $1 = The PUBLIC S3 bucket you want to get the contents of
#
# SQS Arguments
# -------------
# $2 = AWS Account ID for the queue. Something of the form 216689213083
# $3 = queue name that already exists as a SQS on the AWS account. Like Q1
# $4 = url. region the queue exists in. Like sqs.us-east-1.amazonaws.com
# $5 = private key for the AWS account. Something like Vm4iA-Dm3j6GqFlg6lqqHb4x1TQyzI4ccHTk0hSh
# $6 = AWS access key. Something like AKIAIIVRCY63KF3N43YQ


bucket=$1
account=$2
qname=$3
url=$4
hmac=$5
AWSAccessKeyId=$6

read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}

curl http://$bucket.s3.amazonaws.com > /tmp/files.txt
while read_dom; do
    if [[ $ENTITY = "Key" ]] ; then
	filename=$1.s3.amazonaws.com:$CONTENT
	command="../sqs/SQSputV2.sh $account $qname $url $hmac $AWSAccessKeyId $filename"
	curl `$command` >>/tmp/curllog.txt
	echo '-------------' >> /tmp/curllog.txt
    fi
done < /tmp/files.txt
