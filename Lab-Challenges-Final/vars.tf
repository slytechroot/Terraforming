variable "AWS_REGION" {
  default = "us-east-2"
}

variable "AWS_AVAILABILITY_ZONE" {
  default = "us-east-2a"
}

variable "PRIVATE_KEY_PATH" {
  default = "arto-challenges-key-pair"
}

variable "PUBLIC_KEY_PATH" {
  default = "arto-challenges-key-pair.pub"
}

variable "EC2_USER" {
  default = "ubuntu"
}