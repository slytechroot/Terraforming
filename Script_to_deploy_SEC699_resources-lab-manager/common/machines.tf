
resource "aws_instance" "commando_vm" {
  ami           = var.commando_vm_ami
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.public_subnet.id
  private_ip    = "192.168.0.200"

  root_block_device {
    delete_on_termination = true
  }

  tags = {
   Name = "CommandoVM"
   Owner = var.owner
   ScenarioName = var.scenario_name
   ScenarioId = random_uuid.scenario_id.result
   BillingTag = var.billing_tag
  }
}

resource "aws_instance" "dc" {
  ami           = var.dc_ami
  instance_type = "t2.small"
  subnet_id     = aws_subnet.private_subnet.id
  private_ip    = "192.168.20.101"

  root_block_device {
    delete_on_termination = true
  }

  tags = {
   Name = "DC"
   Owner = var.owner
   ScenarioName = var.scenario_name
   ScenarioId = random_uuid.scenario_id.result
   BillingTag = var.billing_tag
  }
}

resource "aws_instance" "win19" {
  ami           = var.win19_ami
  instance_type = "t2.small"
  subnet_id     = aws_subnet.private_subnet.id
  private_ip    = "192.168.20.102"

  root_block_device {
    delete_on_termination = true
  }

  tags = {
   Name = "WIN19"
   Owner = var.owner
   ScenarioName = var.scenario_name
   ScenarioId = random_uuid.scenario_id.result
   BillingTag = var.billing_tag
  }
}
resource "aws_instance" "dc2" {
  ami           = var.dc2_ami
  instance_type = "t2.small"
  subnet_id     = aws_subnet.private_subnet.id
  private_ip    = "192.168.20.103"

  root_block_device {
    delete_on_termination = true
  }

  tags = {
   Name = "DC2"
   Owner = var.owner
   ScenarioName = var.scenario_name
   ScenarioId = random_uuid.scenario_id.result
   BillingTag = var.billing_tag
  }
}

resource "aws_instance" "sql" {
  ami           = var.sql_ami
  instance_type = "t2.small"
  subnet_id     = aws_subnet.private_subnet.id
  private_ip    = "192.168.20.104"

  root_block_device {
    delete_on_termination = true
  }

  tags = {
   Name = "SQL"
   Owner = var.owner
   ScenarioName = var.scenario_name
   ScenarioId = random_uuid.scenario_id.result
   BillingTag = var.billing_tag
  }
}

resource "aws_instance" "win10" {
  ami           = var.win10_ami
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.private_subnet.id
  private_ip    = "192.168.20.105"

  root_block_device {
    delete_on_termination = true
  }

  tags = {
   Name = "WIN10"
   Owner = var.owner
   ScenarioName = var.scenario_name
   ScenarioId = random_uuid.scenario_id.result
   BillingTag = var.billing_tag
  }
}


resource "aws_instance" "soc" {
  ami           = var.soc_ami
  instance_type = "t2.large"
  subnet_id     = aws_subnet.private_subnet.id
  private_ip    = "192.168.20.106"

  root_block_device {
    delete_on_termination = true
  }

  tags = {
   Name = "SOC"
   Owner = var.owner
   ScenarioName = var.scenario_name
   ScenarioId = random_uuid.scenario_id.result
   BillingTag = var.billing_tag
  }
}

resource "aws_instance" "c2" {
  ami           = var.c2_ami
  instance_type = "t2.small"
  subnet_id     = aws_subnet.private_subnet.id
  private_ip    = "192.168.20.107"

  root_block_device {
    delete_on_termination = true
  }
  
  tags = {
   Name = "C2"
   Owner = var.owner
   ScenarioName = var.scenario_name
   ScenarioId = random_uuid.scenario_id.result
   BillingTag = var.billing_tag
  }
}


resource "aws_network_interface_sg_attachment" "commando_vm_attachment" {
  security_group_id    = aws_security_group.commandovm_sec_group.id
  network_interface_id = aws_instance.commando_vm.primary_network_interface_id
}

resource "aws_eip" "commando_vm" {
  instance = aws_instance.commando_vm.id
  vpc = true
}


resource "aws_network_interface_sg_attachment" "dc_attachment" {
  security_group_id    = aws_security_group.lab_security_group.id
  network_interface_id = aws_instance.dc.primary_network_interface_id
}


resource "aws_network_interface_sg_attachment" "win19_attachment" {
  security_group_id    = aws_security_group.lab_security_group.id
  network_interface_id = aws_instance.win19.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "dc2_attachment" {
  security_group_id    = aws_security_group.lab_security_group.id
  network_interface_id = aws_instance.dc2.primary_network_interface_id
}


resource "aws_network_interface_sg_attachment" "sql_attachment" {
  security_group_id    = aws_security_group.lab_security_group.id
  network_interface_id = aws_instance.sql.primary_network_interface_id
}


resource "aws_network_interface_sg_attachment" "win10_attachment" {
  security_group_id    = aws_security_group.lab_security_group.id
  network_interface_id = aws_instance.win10.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "soc_attachment" {
  security_group_id    = aws_security_group.lab_security_group.id
  network_interface_id = aws_instance.soc.primary_network_interface_id
}



resource "aws_network_interface_sg_attachment" "c2_attachment" {
  security_group_id    = aws_security_group.lab_security_group.id
  network_interface_id = aws_instance.c2.primary_network_interface_id
}
