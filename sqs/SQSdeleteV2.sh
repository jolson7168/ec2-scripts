#SQSdeleteV2.sh - command line script to delete a message from a AWS SQS message queue by its receipthandle

# Usage:
# ./SQSdeleteV2.sh 216689213083 Q1 sqs.us-east-1.amazonaws.com Vm4iA-Dm3j6GqFlg6lqqHb4x1TQyzI4ccHTk0hSh AKIAIIVRCY63KF3N43YQ AQEB...

#This will delete a message from queue Q1 located at sqs.us-east-1.amazonaws.com
#on AWS acccount 216689213083 with receipt handle AQEB...

#Arguments
# $1 = AWS Account ID. Something of the form 216689213083
# $2 = queue name that already exists as a SQS on the AWS account. Like Q1
# $3 = url. region the queue exists in. Like sqs.us-east-1.amazonaws.com
# $4 = hmac for the AWS account. Something like Vm4iA-Dm3j6GqFlg6lqqHb4x1TQyzI4ccHTk0hSh
# $5 = AWS access key. Something like AKIAIIVRCY63KF3N43YQ
# $6 = receipt handle - you get this from pulling something successfully from the queue.

#This uses AWS signing V2, and makes the request valid for a duration of 10 minutes after it is signed. 
#It also cheats by encoding the message body using python, so make sure you have that installed

account=$1
qname=$2
httpaction=GET
url=$3
hmac=$4
AWSAccessKeyId=$5
Receipt=$6

Action=DeleteMessage
Expires=`date -d "+30 minutes" -u "+%Y-%m-%dT%H:%M:%SZ"`
EExpires=${Expires//:/%3A}
SignatureMethod=HmacSHA256
SignatureVersion=2
Version=2012-11-05

Receiptencoded=`python -c "import sys, urllib as ul; print ul.quote('$Receipt','')"`
encodestring=$httpaction"\n"$url"\n""/"$account"/"$qname"\n""AWSAccessKeyId="$AWSAccessKeyId"&Action="$Action"&Expires="$EExpires"&ReceiptHandle="$Receiptencoded"&SignatureMethod="$SignatureMethod"&SignatureVersion="$SignatureVersion"&Version="$Version
b64=`echo -ne $encodestring |openssl sha256 -hmac $hmac -binary|base64`
encoded=`python -c "import sys, urllib as ul; print ul.quote_plus('$b64')"`

request=https://$url/$account/$qname"?AWSAccessKeyId="$AWSAccessKeyId"&Action="$Action"&Expires="$EExpires"&SignatureMethod="$SignatureMethod"&SignatureVersion="$SignatureVersion"&Version="$Version"&Signature="$encoded"&ReceiptHandle="$Receiptencoded

echo $request


