#Do Stuff
apt-get update
apt-get install python-pip
apt-get install git
apt-get install python-dev libxml2-dev libxslt-dev
apt-get install python3-dev
apt-get install zlib1g-dev
pip install --user virtualenv
pip install --user virtualenvwrapper
echo "export PATH=$PATH:/home/ubuntu/.local/bin" >>/home/ubuntu/.bashrc
echo "export WORKON_HOME=/home/ubuntu/virtenvs" >>/home/ubuntu/.bashrc
echo "export PROJECT_HOME=/home/ubuntu/Projects-Active" >>/home/ubuntu/.bashrc
echo "source /home/ubuntu/.local/bin/virtualenvwrapper.sh" >>/home/ubuntu/.bashrc
