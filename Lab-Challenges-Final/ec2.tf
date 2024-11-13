# ARTO Domain Controller
resource "aws_instance" "arto-domain-controller" {

    ami = "ami-0dc58c32b93aaeb77"
    instance_type = "t2.medium"

    # VPC
    subnet_id = "${aws_subnet.prod-subnet-public-1.id}"

    # Set Private IP
    private_ip = "10.10.0.128"

    # Security Group
    vpc_security_group_ids = ["${aws_security_group.subnet-dc-sg-allowed.id}"]

    # the Public SSH key
    key_name = "${aws_key_pair.offensive-dev-key-pair.id}"

    tags = {
      Name = "ARTO - Domain Controller"
    }

}

# ARTO ADCS Server
resource "aws_instance" "arto-adcs" {

    ami = "ami-0983a59182b93f4a6"
    instance_type = "t2.medium"

    # VPC
    subnet_id = "${aws_subnet.prod-subnet-public-1.id}"

    # Set Private IP
    private_ip = "10.10.0.66"

    # Security Group
    vpc_security_group_ids = ["${aws_security_group.subnet-adcs-sg-allowed.id}"]

    # the Public SSH key
    key_name = "${aws_key_pair.offensive-dev-key-pair.id}"

    tags = {
      Name = "ARTO - ADCS Server"
    }

}

# ARTO SQL Server
resource "aws_instance" "arto-sql" {

    ami = "ami-0b93f50309587488f"
    instance_type = "t3.xlarge"

    # VPC
    subnet_id = "${aws_subnet.prod-subnet-public-1.id}"

    # Set Private IP
    private_ip = "10.10.0.6"

    # Security Group
    vpc_security_group_ids = ["${aws_security_group.subnet-sql-sg-allowed.id}"]

    # the Public SSH key
    key_name = "${aws_key_pair.offensive-dev-key-pair.id}"

    tags = {
      Name = "ARTO - SQL Server"
    }

}

# ARTO SQL Server
resource "aws_instance" "arto-client-application" {

    ami = "ami-0c9ed46406fe405df"
    instance_type = "t2.medium"

    # VPC
    subnet_id = "${aws_subnet.client-app-subnet-1.id}"

    # Set Private IP
    private_ip = "10.10.30.11"

    # Security Group
    vpc_security_group_ids = ["${aws_security_group.subnet-app-sg-allowed.id}"]

    # the Public SSH key
    key_name = "${aws_key_pair.offensive-dev-key-pair.id}"

    tags = {
      Name = "ARTO - Client Application Server"
    }

}


resource "aws_key_pair" "offensive-dev-key-pair" {
    key_name = "arto-challenges-key-pair"
    public_key = "${file(var.PUBLIC_KEY_PATH)}"
}


