#!/bin/bash

terraform init
terraform destroy -var "scenario_name=SEC699-LAB" -var "owner=SANS" -auto-approve