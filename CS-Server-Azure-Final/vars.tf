variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}






# Static Vars
#
#----------------------------------
variable "AWS_REGION" {
  default = "us-east-2"
}
variable "EC2_USER" {
  default = "ubuntu"
}
variable "EC2_ROOT" {
  default = "root"
}
variable "AZURE_USER" {
  default = "azureuser"
}
variable "AZURE_ROOT" {
  default = "root"
}
#----------------------------------


# Client Name
#
#------------------------------------
variable "CLIENT_NAME" {
  default = "Stigs-Corp"
}
#------------------------------------


# Redirector Domains - Must set at least 1 domain. No sub-domains are supported yet and no www. domains. We set that with a A record
#
#------------------------------------
locals {
  domains = ["ms-updates-windows.com"]
}
#------------------------------------


# Redirector Domains Ports - Must set 1!
#
#------------------------------------
variable "CS-REDIR-PORT-01" {
  default = "4443"
}
#------------------------------------


# CS License key
#
#------------------------------------
variable "CS-SERVER-LICENSE" {
  default = "e741-37fd-617b-0001"
}
#------------------------------------


# Server Names
#
#------------------------------------
variable "CS-SERVER" {
  default = "CS-Server"
}
variable "CS-REDIR-01" {
  default = "CS-Redir01"
}
#------------------------------------

