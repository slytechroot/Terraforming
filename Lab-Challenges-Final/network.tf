# create an IGW (Internet Gateway)
# It enables your vpc to connect to the internet
resource "aws_internet_gateway" "prod-igw" {
    vpc_id = "${aws_vpc.prod-vpc.id}"

    tags = {
        Name = "arto-challenges-prod-igw"
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
        Name = "arto-challenges-prod-public-crt"
    }
}

# route table association for the public subnets
resource "aws_route_table_association" "prod-crta-public-subnet-1" {
    subnet_id = "${aws_subnet.prod-subnet-public-1.id}"
    route_table_id = "${aws_route_table.prod-public-crt.id}"
}

# Add in 2nd subnet
resource "aws_route_table_association" "prod-crta-public-subnet-2" {
    subnet_id = "${aws_subnet.client-app-subnet-1.id}"
    route_table_id = "${aws_route_table.prod-public-crt.id}"
}

# security group for Domain Controller
resource "aws_security_group" "subnet-dc-sg-allowed" {
    name        = "arto-Domain-Controller-sg"
    description = "ARTO SG for DC"
    vpc_id = "${aws_vpc.prod-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

        ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Global RDP Access"
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

    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["10.10.30.0/24"]
        description = "Client Application Subnet Access"
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
    }

    

    tags = {
        Name = "subnet-DC-sg-allowed"
    }
}

# security group for ADCS Server
resource "aws_security_group" "subnet-adcs-sg-allowed" {
    name        = "arto-ADCS-sg"
    description = "ARTO SG for ADCS"
    vpc_id = "${aws_vpc.prod-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

        ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Global RDP Access"
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
        Name = "subnet-ADCS-sg-allowed"
    }
}

# security group for SQL Server
resource "aws_security_group" "subnet-sql-sg-allowed" {
    name        = "arto-SQL-sg"
    description = "ARTO SG for SQL"
    vpc_id = "${aws_vpc.prod-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Global RDP Access"
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
    }

    ingress {
        from_port = 1433
        to_port = 1433
        protocol = "tcp"
        cidr_blocks = ["10.10.30.11/32"]
        description = "Internal SQL access to Client Host"
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
        Name = "subnet-SQL-sg-allowed"
    }
}

# security group for Client Application Server
resource "aws_security_group" "subnet-app-sg-allowed" {
    name        = "arto-Client-App-sg"
    description = "ARTO SG for Client Application"
    vpc_id = "${aws_vpc.prod-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Global RDP Access"
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
    }

    ingress {
        from_port = 445
        to_port = 445
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Global SMB Access"
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
        Name = "subnet-Client-App-sg-allowed"
    }
}