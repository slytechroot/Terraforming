variable "billing_tag" {
  default = "Firing-Range"
}

variable "owner" {
  default = "null"
}

variable "scenario_name" {
  default = "SEC699-LAB"
}

resource "aws_key_pair" "auth" {
  key_name_prefix   = "vpn"
  public_key = file("${var.ssh_key_path}_${var.aws_region}_${var.version_tag}.pub")
}

resource "random_uuid" "scenario_id" { }

variable "ssh_key_path" {
  type    = string
  default = "./ssh_key"
}


variable "commando_vm_ami" {}
variable "dc_ami" {}
variable "dc2_ami" {}
variable "win19_ami" {}
variable "win10_ami" {}
variable "sql_ami" {}
variable "soc_ami" {}
variable "c2_ami" {}
variable "version_tag" {}
variable "aws_region" {}

