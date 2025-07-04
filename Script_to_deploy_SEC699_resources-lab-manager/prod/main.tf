variable "version_tag" {
  default = "v0.0.6"
}

variable "ami_owner" {
  default = "195392357845"
}

data "aws_ami" "commando_vm" {
  most_recent      = true
  owners           = [var.ami_owner]
  filter {
    name   = "name"
    values = ["AMI-SEC699-LAB-CommandoVM-${var.version_tag}"]
  }
}

data "aws_ami" "c2" {
  most_recent      = true
  owners           = [var.ami_owner]
  filter {
    name   = "name"
    values = ["AMI-SEC699-LAB-C2-${var.version_tag}"]
  }
}

data "aws_ami" "soc" {
  most_recent      = true
  owners           = [var.ami_owner]
  filter {
    name   = "name"
    values = ["AMI-SEC699-LAB-SOC-${var.version_tag}"]
  }
}

data "aws_ami" "win19" {
  most_recent      = true
  owners           = [var.ami_owner]
  filter {
    name   = "name"
    values = ["AMI-SEC699-LAB-WIN19-${var.version_tag}"]
  }
}

data "aws_ami" "dc" {
  most_recent      = true
  owners           = [var.ami_owner]
  filter {
    name   = "name"
    values = ["AMI-SEC699-LAB-DC-${var.version_tag}"]
  }
}

data "aws_ami" "dc2" {
  most_recent      = true
  owners           = [var.ami_owner]
  filter {
    name   = "name"
    values = ["AMI-SEC699-LAB-DC2-${var.version_tag}"]
  }
}

data "aws_ami" "win10" {
  most_recent      = true
  owners           = [var.ami_owner]
  filter {
    name   = "name"
    values = ["AMI-SEC699-LAB-WIN10-${var.version_tag}"]
  }
}

data "aws_ami" "sql" {
  most_recent      = true
  owners           = [var.ami_owner]
  filter {
    name   = "name"
    values = ["AMI-SEC699-LAB-SQL-${var.version_tag}"]
  }
}

variable "owner" {}

variable "aws_region" {
  default = "eu-west-1"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}


module "sec699" {
  source = "../common"
  owner = var.owner
  version_tag = var.version_tag
  aws_region = var.aws_region
  commando_vm_ami = data.aws_ami.commando_vm.id
  c2_ami = data.aws_ami.c2.id
  soc_ami = data.aws_ami.soc.id
  sql_ami = data.aws_ami.sql.id
  win10_ami = data.aws_ami.win10.id
  win19_ami = data.aws_ami.win19.id
  dc2_ami = data.aws_ami.dc2.id
  dc_ami = data.aws_ami.dc.id
}

output "commando_vm_ip" {
  value = module.sec699.commando_vm_ip
}