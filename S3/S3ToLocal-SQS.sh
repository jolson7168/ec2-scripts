#!/bin/bash

# S3toLocal-SQS
# -------------
# This script assumes a SQS queue is loaded up with a bunch of addresses of files
# stored in S3. This script will pull the addresses out, download them to the local
# machine, and unzip them one by one until the queue is empty. 
#
# It is intended for multiple machine to each execute this script to pull big data
# out of S3 and load it into an HDFS file store running in parallel
#
# NOTES: for this script, the S3 bucket must be public, the SQS queue can be private.
# This script will only go one level deep on the bucket
# The queue items are of the form <s3 bucket>:<key> 

#Arguments
#
# SQS Arguments
# -------------
# $1 = AWS Account ID for the queue. Something of the form 216689213083
# $2 = queue name that already exists as a SQS on the AWS account. Like Q1
# $3 = url. region the queue exists in. Like sqs.us-east-1.amazonaws.com
# $4 = private key for the AWS account. Something like Vm4iA-Dm3j6GqFlg6lqqHb4x1TQyzI4ccHTk0hSh
# $5 = AWS access key. Something like AKIAIIVRCY63KF3N43YQ
# $6 = address where you want the downloaded file to go on the local machine

account=$1
qname=$2
url=$3
hmac=$4
AWSAccessKeyId=$5
localdir=$6

read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}

request=`../sqs/SQSgetV2.sh $account $qname $url $hmac $AWSAccessKeyId`
xml=`curl $request`
done=false
while [ "$done" = false ]; do
	if [[ $xml == *"<ReceiveMessageResult/>"* ]] ; then
		 done=true
	else
		while read_dom; do
		    if [[ $ENTITY = "Body" ]] ; then
			filename=http://${CONTENT//://}
			wget -P $localdir/ $filename
			IFS='/' read -ra ADDR <<< "$filename"
			for i in "${ADDR[@]}"; do
				fname2="$i"
			done
			unzip $localdir/$fname2 -d $localdir
	    	    fi
		    if [[ $ENTITY = "ReceiptHandle" ]] ; then
			handle=$CONTENT
			deleterequest=`../sqs/SQSdeleteV2.sh $account $qname $url $hmac $AWSAccessKeyId $handle`
			deleted=`curl $deleterequest`
		    fi
		done <<< "$xml"
		request=`../sqs/SQSgetV2.sh $account $qname $url $hmac $AWSAccessKeyId`
		xml=`curl $request`
	fi
done
