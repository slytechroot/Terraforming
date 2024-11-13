# Attacker Kali Box
resource "aws_instance" "attacker-kali-box" {

    ami = "ami-08ed25d33eda30284"
    instance_type = "t2.medium"

    # VPC
    subnet_id = "${aws_subnet.prod-subnet-public-1.id}"

    # Set Private IP
    private_ip = "10.10.0.229"

    # Security Group
    vpc_security_group_ids = ["${aws_security_group.subnet-sg-allowed.id}"]

    # the Public SSH key
    key_name = "${aws_key_pair.offensive-dev-key-pair.id}"

    connection {
        user = "admin"
        host = "${aws_instance.attacker-kali-box.public_ip}"
        private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
    }

    tags = {
      Name = "ARTO - Attacker Linux"
    }

}

# Windows Dev Box
resource "aws_instance" "windows-dev-box" {

    ami = "ami-0d2a70ceefe23a71d"
    instance_type = "t2.large"

    # VPC
    subnet_id = "${aws_subnet.prod-subnet-public-1.id}"

    # Set Private IP
    private_ip = "10.10.0.122"

    # Security Group
    vpc_security_group_ids = ["${aws_security_group.subnet-sg-allowed.id}"]

    # the Public SSH key
    key_name = "${aws_key_pair.offensive-dev-key-pair.id}"

    tags = {
      Name = "ARTO - Windows Dev Box"
    }

}

# Guacamole Server
resource "aws_instance" "guacamole-server" {

    ami = "ami-05e2ddfa0ef03ce31"
    instance_type = "t2.medium"

    # VPC
    subnet_id = "${aws_subnet.prod-subnet-public-1.id}"

    # Set Private IP
    private_ip = "10.10.0.50"

    # Security Group
    vpc_security_group_ids = ["${aws_security_group.guacamole-server-sg-allowed.id}"]

    # the Public SSH key
    key_name = "${aws_key_pair.offensive-dev-key-pair.id}"

    connection {
        user = "admin"
        host = "${aws_instance.guacamole-server.public_ip}"
        private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
    }

    tags = {
      Name = "ARTO - Guacamole Server"
    }

}

resource "aws_key_pair" "offensive-dev-key-pair" {
    key_name = "arto-key-pair"
    public_key = "${file(var.PUBLIC_KEY_PATH)}"
}

# Create Elastic IP for the Guacamole Server EC2 instance
resource "aws_eip" "guacamole-server-eip" {
  vpc  = true
  tags = {
    Name = "guacamole-server-eip"
  }
}
# Associate Elastic IP to Windows Server
resource "aws_eip_association" "guacamole-server-eip-association" {
  instance_id   = aws_instance.guacamole-server.id
  allocation_id = aws_eip.guacamole-server-eip.id
}