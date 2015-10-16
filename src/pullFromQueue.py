from __future__ import print_function      # get latest print functionality

###################################################
# Python standard modules (libraries)

import os.path
import math
import functools 
import sys
import time               # sleep function for connection back-off
import datetime
import json   
import pika               # RabbitMQ AMQP client
import getopt
import logging
import boto
import zipfile
from riak import RiakClient
from riak import RiakObject

riak = None

def configureRiak(riakIPs, riakPort):
    logger = logging.getLogger("pullfromQueue")
    initial_attempts = 5
    num_attempts = 0

    initial_delay = 5      # 5 seconds between between initial attempts
    longer_delay = 5*60    # 5 minutes = 300 seconds
    delay_time = initial_delay

    nodes=[]
    for eachNode in riakIPs.split(","):
        thisNode= { 'host': eachNode, 'pb_port': riakPort}
        nodes.append(thisNode)

    riakIP=""
    for node in nodes:
        riakIP=json.dumps(node)+ " - " +riakIP

    logger.info('[STATE] Connecting to Riak...')

    connected = False  
    client = RiakClient(protocol='pbc',nodes=nodes)
    while not connected:
       try:
            logger.info("Attempting to PING....")
            client.ping()
            connected = True
       except:
            num_attempts += 1
            logger.error('EXCP: No Riak server found')
            if num_attempts == initial_attempts:
                delay_time = longer_delay
                # Wait to issue next connection attempt
                time.sleep(delay_time)

    logger.info('[STATE] Connected to Riak. Successful PING')
    return client


def getFile(bucket, keyname):
    conn = boto.connect_s3(anon=True)
    bucket = conn.get_bucket(bucket)
    key = bucket.get_key(keyname)
    bucketContents = key.get_contents_to_filename("/tmp/"+keyname)
    return "/tmp/"+keyname


def unzipFile(fname):
    with zipfile.ZipFile(fname, "r") as z:
        z.extractall("/tmp")


def toInteger(tmstmp):
    #20150211 23:58
    return int(time.mktime(datetime.datetime.strptime(tmstmp, "%Y%m%d %H:%M").timetuple()))

def writeRiak(action, fix):
    global riak

    logger = logging.getLogger("pullfromQueue")
    bucketname = str(fix["vid"])
    key = str(toInteger(fix["tmstmp"]))
    bucket = riak.bucket(bucketname)
    if action == "write":
        obj = RiakObject(riak, bucket, key)
        obj.content_type = "application/json"
        obj.data = fix
        index = None
        if index is not None:
                for indexKey in index:
                    try:
                        obj.add_index(indexKey,index[indexKey])
                    except Exception as e:
                        logger.error("Error updating index: "+e.message)
        startTime = time.time()
        storedObj = obj.store()
        duration = round((time.time() - startTime),3)
        if storedObj is not None:
            results = storedObj.key
        else:
            results = "Not stored!"
        logger.info(" Write "+bucketname+"/"+key+" Sz: "+str(len(json.dumps(fix)))+" Dur: "+str(duration)+" Results: "+results)
    elif action == "delete":
        got = bucket.get(key)
        startTime = time.time()
        got.delete()
        duration = round((time.time() - startTime),3)
        logger.info(" Block delete "+(bucketname[-3:])+"/"+key+" Duration: "+str(duration))
    elif action == "test":
        print(key)

def toRiakIndividual(fname):
    logger = logging.getLogger("pullfromQueue")
    startTime = time.time()
    with open(fname) as fixFile: 
        for fix in fixFile:
            if "vid" in fix:
                print(fix)
                print("---")
                print(fix.replace("},","}"))
                writeRiak("write", json.loads(fix.replace("},","}")))
    duration = round((time.time() - startTime),3)   
    logger.info("Loaded fix file individually. Duration: "+str(duration))
    for fix in fixes["fixes"]:
        writeRiak("write", fix)


def toRiak(fname):
    logger = logging.getLogger("pullfromQueue")
    startTime = time.time()
    with open(fname) as data_file:
        fixes = json.loads(data_file)
    duration = round((time.time() - startTime),3)   
    logger.info("Loaded fix file. Duration: "+str(duration))
    for fix in fixes["fixes"]:
        writeRiak("write", fix)

def processFile(channel, method, properties, body):
    logger = logging.getLogger("pullfromQueue")
    fileInfo=json.loads(body)
    logger.info("Working: "+fileInfo["bucket"]+" "+fileInfo["filename"])
    thisFile = getFile(fileInfo["bucket"], fileInfo["filename"])
    unzipFile(thisFile)
    toRiakIndividual(thisFile)
    channel.basic_ack(delivery_tag=method.delivery_tag)

def configureMsgConsumer(server, queue_to_process, login, password, callback_func):

    ############################################################
    # Create a connection to a machine with a RabbitMQ server
    # server can be replaced by any server name or IP
    #
    logger = logging.getLogger("pullfromQueue")
    initial_attempts = 5
    num_attempts = 0

    initial_delay = 5      # 5 seconds between between initial attempts
    longer_delay = 5*60    # 5 minutes = 300 seconds
    delay_time = initial_delay

    connected = False
    logger.info('[STATE] Consumer connecting to RabbitMQ at {0}'.format(server))

    connection, channel = None, None

    while not connected:
        try:
            credentials = pika.PlainCredentials(login, password)
            connection = pika.BlockingConnection(pika.ConnectionParameters(server,credentials=credentials))

            # Create a channel to pass messages through
            channel = connection.channel()

            ############################################################
            # Set pre-fetch count to 1 to distribute messages evenly
            # among clients
            channel.basic_qos(prefetch_count=1)

            ############################################################
            # Attach a callback function to the queue of interest to
            # be activated when a queue message is received
            #
            # queue = queue_to_process must already exist
            #
            channel.basic_consume(callback_func, queue=queue_to_process)

            connected = True

        except pika.exceptions.AMQPConnectionError as e:
            # For a connection error wait for a short time before re-trying
            num_attempts += 1

            logger.info('[STATE] RabbitMQ consumer connection error - attempt {0} error: {1}'.format(
                num_attempts, str(e)))

            if num_attempts == initial_attempts:
                delay_time = longer_delay

            # Wait to issue next connection attempt
            time.sleep(delay_time)

    # Log connection
    logger.info('[STATE] Consumer connected to RabbitMQ at {0}'.format(server))

    return connection, channel

def initLog(rightNow):
    logger = logging.getLogger("pullfromQueue")
    logPath='/tmp/'
    logFilename=".log"
    hdlr = logging.FileHandler(logPath+rightNow+logFilename)
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s","%Y-%m-%d %H:%M:%S")
    hdlr.setFormatter(formatter)
    logger.addHandler(hdlr) 
    logger.setLevel(logging.INFO)
    return logger



def main(argv):
    global riak 

    rightNow = time.strftime("%Y%m%d%H%M%S")
    logger = initLog(rightNow)
    riak = configureRiak("130.211.186.161", "8087")

    try:
        opts, args = getopt.getopt(argv,"hslpq:",["server=","login=","password=","queue="])
    except getopt.GetoptError:
        print ('pullFromQueue.py -s <ip of queue server> -l <login> -p <password> -q <queue>')
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print ('pullFromQueue.py -s <ip of queue server> -l <login> -p <password> -q <queue>')
            sys.exit()
        elif opt in ("-s", "--server"):
            server=arg
        elif opt in ("-l", "--login"):
            login=arg
        elif opt in ("-p", "--password"):
            password=arg
        elif opt in ("-q", "--queue"):
            queue=arg

#    toRiakIndividual('/tmp/20150212.json')
    gConnection, gChannel = configureMsgConsumer(server, queue, login, password, processFile)
    gChannel.start_consuming()
    gConnection.close()

if __name__ == "__main__":
    main(sys.argv[1:])