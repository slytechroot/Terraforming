resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = var.scenario_name
    Owner = var.owner
    ScenarioName = var.scenario_name
    BillingTag = var.billing_tag
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "192.168.0.0/24"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Public subnet"
    Owner = var.owner
    ScenarioName = var.scenario_name
    BillingTag = var.billing_tag
  }
}

resource "aws_subnet" "private_subnet" {
  depends_on        = [ aws_subnet.public_subnet ]
  availability_zone = aws_subnet.public_subnet.availability_zone
  vpc_id            = aws_vpc.main.id
  cidr_block        = "192.168.20.0/24"
  tags = {
    Name = "Private subnet"
    Owner = var.owner
    ScenarioName = var.scenario_name
    BillingTag = var.billing_tag
  }
}

resource "aws_internet_gateway" "nat_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "NAT gateway"
    Owner = var.owner
    ScenarioName = var.scenario_name
    BillingTag = var.billing_tag
  }
}

resource "aws_route_table" "nat_gateway" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "nat_gateway" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.nat_gateway.id
}

data "aws_ami" "nat" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "access_via_nat" {
  name = "Access to nat instance"
  description = "Access to internet via nat instance for private nodes"
  vpc_id = aws_vpc.main.id

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_inbound_traffic_1" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "all"
  cidr_blocks = [aws_subnet.private_subnet.cidr_block]
  security_group_id = aws_security_group.access_via_nat.id
}

resource "aws_security_group_rule" "allow_inbound_traffic_from_my_ip" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "all"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.access_via_nat.id
}

# Nat instance #1
resource "aws_instance" "nat_1" {
  ami                         = data.aws_ami.nat.id
  instance_type               = "t3.nano"
  source_dest_check           = false
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.access_via_nat.id]
  key_name                    = aws_key_pair.auth.key_name


  root_block_device {
    delete_on_termination = true
  }
  
  tags = {
    Name = "NAT instance"
    Owner = var.owner
    ScenarioName = var.scenario_name
    BillingTag = var.billing_tag
  }

  provisioner "file" {
    source      = "../common/artifacts/manage_openvpn.sh"
    destination = "/tmp/manage_openvpn.sh"
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.ssh_key_path}_${var.aws_region}_${var.version_tag}")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/manage_openvpn.sh",
      "sudo /tmp/manage_openvpn.sh -i ",
      "sudo /tmp/manage_openvpn.sh -a student",
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${var.ssh_key_path}_${var.aws_region}_${var.version_tag}")
    }
  }

  provisioner "local-exec" {
    command = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${var.ssh_key_path}_${var.aws_region}_${var.version_tag} ec2-user@${self.public_ip}:/etc/openvpn/student.ovpn ..; mv ../student.ovpn ../student_${var.aws_region}_${var.version_tag}.ovpn;"
  }
}

resource "aws_route_table" "private_subnet" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = aws_instance.nat_1.id
  }
}

resource "aws_route_table_association" "private_subnet" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_subnet.id
}

data "http" "myip" {
  url = "https://api.ipify.org/?format=plain"
}

resource "aws_security_group" "commandovm_sec_group" {
  name        = "allow_all_commando_vm"
  description = "${var.scenario_name} - Commando VM security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow all ingress from my IP or VPN"
    protocol    = "-1"
    to_port     = 0
    from_port   = 0
    cidr_blocks = ["${chomp(data.http.myip.body)}/32", "${aws_instance.nat_1.private_ip}/32"]
  }

  egress {
    description = "Allow all egress"
    protocol    = "-1"
    to_port     = 0
    from_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.scenario_name} - CommandoVM security group"
    Owner = var.owner
    ScenarioName = var.scenario_name
    BillingTag = var.billing_tag
  }
}

resource "aws_security_group" "lab_security_group" {
  name        = "student_lab_security_group"
  description = "${var.scenario_name} - Lab security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow all ingress"
    protocol    = "-1"
    to_port     = 0
    from_port   = 0
    cidr_blocks = [aws_subnet.private_subnet.cidr_block, "${aws_instance.commando_vm.private_ip}/32", "${aws_instance.nat_1.private_ip}/32"]
  }

  egress {
    description = "Allow all egress"
    protocol    = "-1"
    to_port     = 0
    from_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Student security group"
    Owner = var.owner
    ScenarioName = var.scenario_name
    BillingTag = var.billing_tag
  }
}
