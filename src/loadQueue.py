import json
import csv
import pika
import sys
import getopt
import boto


def sendData(uploadFile, queueserver, login, password, exchange, route, action, uuid):

	credentials = pika.PlainCredentials(login, password)
	connection = pika.BlockingConnection(pika.ConnectionParameters(queueserver,credentials=credentials))
	channel = connection.channel()

	try:
		ifile  = open(uploadFile, "rb")
		reader = csv.reader(ifile)
		for row in reader:
			if not row[0][0]=="#":
					if uuid is None:
						msg={"action":action,"id":row[0],"startTime":int(row[1]),"endTime":int(row[2]),"interval":int(row[3]),"size":int(row[4])}
					else:
						msg={"action":action,"id":uuid,"startTime":int(row[0]),"endTime":int(row[1]),"interval":int(row[2]),"size":int(row[3])}
					channel.basic_publish(exchange=exchange,routing_key=route,body=json.dumps(msg))
					print "Sent: "+json.dumps(msg)
	except Exception as e:
		print ("Error loading queue data: "+e.message)

	connection.close()


def getKeysFromBucket(bucket):
	retval=[]
	conn = boto.connect_s3(anon=True)
	bucket = conn.get_bucket(bucket)
	for key in bucket.list():
		retval.append({"bucket":bucket, "filename":key.name.encode('utf-8')})
	return retval

def getFile(s3Key):
	conn = boto.connect_s3(anon=True)
	bucket = conn.get_bucket(s3Key["bucket"])
	key = bucket.get_key(s3Key["filename"])
	bucketContents = key.get_contents_to_filename("/tmp/"+s3Key["filename"])
	print(bucketContents)

def main(argv):
 	try:
		opts, args = getopt.getopt(argv,"hsqlper:",["s3bucket=","queueserver=","login=","password=","exchange=","route="])
	except getopt.GetoptError:
		print ('loadQueue.py -s <S3 bucket listing files> -q <ip of queue server> -l <login> -p <password> -e <exchange> -r <route>')
		sys.exit(2)

	for opt, arg in opts:
		if opt == '-h':
			print ('loadQueue.py -s <S3 bucket listing files> -q <ip of queue server> -l <login> -p <password> -e <exchange> -r <route>')
			sys.exit()
		elif opt in ("-s", "--s3bucket"):
			bucket=arg
			#try:
			#except IOError:
			#	print ('s3 Bucket: '+bucket+' not found')
			#	sys.exit(2)
		elif opt in ("-q", "--queueserver"):
			queueserver=arg
		elif opt in ("-l", "--login"):
			login=arg
		elif opt in ("-p", "--password"):
			password=arg
		elif opt in ("-e", "--exchange"):
			exchange=arg
		elif opt in ("-r", "--route"):
			route=arg

	files = getKeysFromBucket(bucket) #, queueserver, login, password, exchange, route)
	getFile(files[0])

if __name__ == "__main__":
	main(sys.argv[1:])