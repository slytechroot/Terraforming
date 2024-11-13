# create an IGW (Internet Gateway)
# It enables your vpc to connect to the internet
resource "aws_internet_gateway" "prod-igw" {
    vpc_id = "${aws_vpc.prod-vpc.id}"

    tags = {
        Name = "arto-prod-igw"
    }
}

# create a custom route table for public subnets
# public subnets can reach to the internet buy using this
resource "aws_route_table" "prod-public-crt" {
    vpc_id = "${aws_vpc.prod-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0" //associated subnet can reach everywhere
        gateway_id = "${aws_internet_gateway.prod-igw.id}" //CRT uses this IGW to reach internet
    }

    tags = {
        Name = "arto-prod-public-crt"
    }
}

# route table association for the public subnets
resource "aws_route_table_association" "prod-crta-public-subnet-1" {
    subnet_id = "${aws_subnet.prod-subnet-public-1.id}"
    route_table_id = "${aws_route_table.prod-public-crt.id}"
}

# security group for Subnet - Internal Servers
resource "aws_security_group" "subnet-sg-allowed" {
    name        = "arto-subnet-sg"
    description = "Allow subnet traffic to all hosts"
    vpc_id = "${aws_vpc.prod-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["10.10.0.0/24"]
        description = "Subnet All Access"
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
    }

    

    tags = {
        Name = "subnet-sg-allowed"
    }
}

# security group for Guac Server
resource "aws_security_group" "guacamole-server-sg-allowed" {
    name        = "arto-guacamole-sg"
    description = "Allow traffic to Guacamole Host"
    vpc_id = "${aws_vpc.prod-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Guacamole Server HTTPS Access"
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Guacamole Server Tomcat 8080 Access"
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
    }

        ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Guacamole Server SSH Access"
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
    }

        ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["10.10.0.0/24"]
        description = "Subnet All Access"
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
    }

    

    tags = {
        Name = "guacamole-server-sg-allowed"
    }
}