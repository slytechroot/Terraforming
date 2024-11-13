resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.10.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    instance_tenancy = "default"

    tags = {
        Name = "arto-challenges-prod-vpc"
    }
}

resource "aws_subnet" "prod-subnet-public-1" {
    vpc_id = "${aws_vpc.prod-vpc.id}"
    cidr_block = "10.10.0.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "us-east-2a"

    tags = {
        Name = "prod-subnet-public-1"
    }
}

#subnet #2 fpr Client Application Server
resource "aws_subnet" "client-app-subnet-1" {
    vpc_id = "${aws_vpc.prod-vpc.id}"
    cidr_block = "10.10.30.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "us-east-2a"

    tags = {
        Name = "client-app-subnet-1"
    }
}