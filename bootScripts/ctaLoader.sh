
#default machine 4core, 15GB. Can run 4 threads (see below). But we will only run 3.
echo "deb http://archive.ubuntu.com/ubuntu/ vivid universe" | sudo tee -a "/etc/apt/sources.list"
sudo apt-get update
sudo apt-get -y install python-pip
sudo apt-get -y install python-dev libffi-dev libssl-dev
sudo pip install cryptography
sudo pip install pika
sudo pip install riak
#git clone https://github.com/jolson7168/ec2-scripts.git /home/jjo31420/ec2-scripts
echo "python ../src/pullFromQueue.py --server 104.154.89.97 --login login --password password --queue cta" > /home/jjo31420/ec2-scripts/scripts/pullFromQueue.sh
chmod +x /home/jjo31420/ec2-scripts/scripts/pullFromQueue.sh

# Number of cores - 1
#/home/jjo31420/ec2-scripts/scripts/pullFromQueue.sh &
#sleep 10
#/home/jjo31420/ec2-scripts/scripts/pullFromQueue.sh &
#sleep 10
#/home/jjo31420/ec2-scripts/scripts/pullFromQueue.sh &
#sleep 10