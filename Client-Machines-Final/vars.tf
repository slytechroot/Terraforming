variable "AWS_REGION" {
  default = "us-west-2"
}

variable "AWS_AVAILABILITY_ZONE" {
  default = "us-west-2a"
}

variable "PRIVATE_KEY_PATH" {
  default = "arto-key-pair"
}

variable "PUBLIC_KEY_PATH" {
  default = "arto-key-pair.pub"
}

variable "EC2_USER" {
  default = "ubuntu"
}