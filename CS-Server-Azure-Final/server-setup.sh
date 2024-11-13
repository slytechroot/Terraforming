#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

echo "Start of CS Server Install Script"

# Set important Vars
Uname="root"
Password=`openssl rand -hex 16`

#Changing Root Password
echo "Changing Root account password"
echo ${Uname}:${Password} | sudo chpasswd

# Setup SSH
echo "Configure SSH for Tunnel access"
sudo echo -e "\nPermitTunnel yes" >> /etc/ssh/sshd_config
sudo service ssh reload

# Update box
echo "Updating box.."
sudo apt update && sudo apt upgrade -y && sudo apt install net-tools unzip nmap -y

echo "Killing Script"
exit 0


