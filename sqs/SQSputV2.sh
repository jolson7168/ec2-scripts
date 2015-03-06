#SQSputV2.sh - command line scipt to insert a message into a AWS SQS message queue. 

# Usage:
# ./SQSputV2.sh 216689213083 Q1 sqs.us-east-1.amazonaws.com Vm4iA-Dm3j6GqFlg6lqqHb4x1TQyzI4ccHTk0hSh AKIAIIVRCY63KF3N43YQ '{message_id:1,message:"Hello World!"}'

#This will insert the message '{message_id:1,message:"Hello World!"}' into queue Q1 located at sqs.us-east-1.amazonaws.com
#on AWS acccount 216689213083

#Arguments
# $1 = AWS Account ID. Something of the form 216689213083
# $2 = queue name that already exists as a SQS on the AWS account. Like Q1
# $3 = url. region the queue exists in. Like sqs.us-east-1.amazonaws.com
# $4 = hmac for the AWS account. Something like Vm4iA-Dm3j6GqFlg6lqqHb4x1TQyzI4ccHTk0hSh
# $5 = AWS access key. Something like AKIAIIVRCY63KF3N43YQ
# $6 = item to enqueue. Like {message_id:1,message:"Hello World!"}

#This uses AWS signing V2, and makes the request valid for a duration of 10 minutes after it is signed. 
#It also cheats by encoding the message body using python, so make sure you have that installed

account=$1
qname=$2
httpaction=GET
url=$3
hmac=$4
AWSAccessKeyId=$5
MessageBody=$6

Action=SendMessage
Expires=`date -d "+10 minutes" -u "+%Y-%m-%dT%H:%M:%SZ"`
EExpires=${Expires//:/%3A}
SignatureMethod=HmacSHA256
SignatureVersion=2
Version=2012-11-05

MessageBodyEncoded=`python -c "import sys, urllib as ul; print ul.quote('$MessageBody','')"`
encodestring=$httpaction"\n"$url"\n""/"$account"/"$qname"\n""AWSAccessKeyId="$AWSAccessKeyId"&Action="$Action"&Expires="$EExpires"&MessageBody="$MessageBodyEncoded"&SignatureMethod="$SignatureMethod"&SignatureVersion="$SignatureVersion"&Version="$Version

b64=`echo -ne $encodestring |openssl sha256 -hmac $hmac -binary|base64`
encoded=`python -c "import sys, urllib as ul; print ul.quote_plus('$b64')"`
#echo $encoded

request=https://$url/$account/$qname"?AWSAccessKeyId="$AWSAccessKeyId"&Action="$Action"&Expires="$EExpires"&MessageBody="$MessageBodyEncoded"&SignatureMethod="$SignatureMethod"&SignatureVersion="$SignatureVersion"&Version="$Version"&Signature="$encoded

echo $request
