#!/bin/bash
# install_docker.sh

echo "dpkg -l docker : "
dpkg -l docker
sudo apt-get update

echo ""
echo "install apt-transport-https ca-certificates curl software-properties-common : "
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

echo ""
echo "apt-key add : "
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo ""
echo "fingerprint : "
sudo apt-key fingerprint 0EBFCD88

echo ""
echo "add repository : "
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable edge test"
sudo apt-get update

echo ""
echo "install docker-ce : "
sudo apt-get install -y docker-ce=17.03.2~ce-0~ubuntu-xenial
sudo docker run hello-world
sudo docker info

# end
