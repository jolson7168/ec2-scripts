import json
import csv
import pika
import sys
import getopt
import boto


def loadQueue(files, queueserver, login, password, exchange, route):

	credentials = pika.PlainCredentials(login, password)
	connection = pika.BlockingConnection(pika.ConnectionParameters(queueserver,credentials=credentials))
	channel = connection.channel()

	try:
		for eachFile in files:
			channel.basic_publish(exchange=exchange,routing_key=route,body=json.dumps(eachFile))
			print "Sent: "+json.dumps(eachFile)
	except Exception as e:
		print ("Error loading queue data: "+e.message)
	connection.close()



def getKeysFromBucket(bucketname):
	retval=[]
	conn = boto.connect_s3(anon=True)
	bucket = conn.get_bucket(bucketname)
	for key in bucket.list():
		retval.append({"bucket":bucketname, "filename":key.name.encode('utf-8')})
	return retval

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

	files = getKeysFromBucket(bucket) 
	loadQueue(files, queueserver, login, password, exchange, route)

if __name__ == "__main__":
	main(sys.argv[1:])