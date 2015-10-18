from riak import RiakClient
from riak import RiakObject


def testCluster(IPs, login, password):

        initial_attempts = 5
        port = 8087
        num_attempts = 0

        nodes = []
        for eachNode in IPs.split(","):
            thisNode = {'host': eachNode, 'pb_port': port}
            nodes.append(thisNode)

        connected = False
        client = RiakClient(protocol='pbc', nodes=nodes)
        try:
            with client.retry_count(initial_attempts):
                connected = client.ping()
        except Exception as e:
            print('[EXCP] No Riak server found after ' + str(initial_attempts) + " tries. Error: " + str(e))

        if connected:
            print('[STATE] Successful PING! Connected to Riak!')

testCluster("130.211.171.31","riak","riak")