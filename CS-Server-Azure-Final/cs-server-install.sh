#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

echo "Start of CS Server Install Script"

# Docker Install
echo "Setting up Docker"
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install docker-ce -y

# Git clone down the project
sudo git clone https://github.com/WKL-Sec/docker-cobaltstrike.git /opt/docker-cobaltstrike

#crate dir for cobalt stike profile
#sudo mkdir /opt/cobaltstrike

XE=$(cat lic.txt)
XX="6245dafabeaead6dce8f8f3578ac4ba6"
LIC=`echo $XE | openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:$XX`

# Build Cobalt strike container
sudo docker build -t cobaltstrike /opt/docker-cobaltstrike

docker create \
  --name=cobaltstrike \
  -e TZ=America/New_York \
  -e COBALTSTRIKE_KEY=$LIC \
  -e COBALTSTRIKE_PASS=password \
  -e COBALTSTRIKE_EXP=2028-12-20 \
  -e COBALTSTRIKE_PROFILE=cs.profile \
  -p 50050:50050 \
  -p 9050:9050 \
  -p 9051:9051 \
  -p 9052:9052 \
  -p 9053:9053 \
  -p 9054:9054 \
  -p 9055:9055 \
  -p 9056:9056 \
  -p 443:443 \
  -p 4443:4443 \
  -p 4444:4444 \
  -p 4445:4445 \
  -p 4446:4446 \
  -p 4447:4447 \
  -p 4448:4448 \
  -p 4449:4449 \
  -p 80:80 \
  -v /opt/cobaltstrike:/opt/cobaltstrike \
  --restart unless-stopped \
  cobaltstrike

# Start docker and run CS container
sudo docker start cobaltstrike

echo "Killing Script"
exit 0


