#!/bin/bash

rm ssh_key ssh_key.pub 2> /dev/null

KEY_PATH="$(pwd)/ssh_key"
echo "Generating ssh key $KEY_PATH"
ssh-keygen -b 2048 -t rsa -f "$KEY_PATH" -q -N ""
chmod 0600 ssh_key
terraform init


terraform init
terraform apply -var "scenario_name=SEC699-LAB" -var "owner=SANS" -auto-approve