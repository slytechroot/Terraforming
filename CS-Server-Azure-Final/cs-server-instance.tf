# Create public IPs
resource "azurerm_public_ip" "arto_cs_server_public_ip" {
  name                = "ARTO-CS-Server"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "arto_cs_server_nsg" {
  name                = "ARTO-CS-Server-NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "SubnetAccess"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.10.25.0/24"
    destination_address_prefix = "*"
  }
  # CS Client Access rules - Windows Dev Box - Add IP here
    security_rule {
    name                       = "CS_Windows_Dev_Client_Access"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50050"
    source_address_prefix      = "34.219.217.146/32"
    destination_address_prefix = "*"
  }
    # CS Client Access rules - Attacker Kali - Add IP here
      security_rule {
    name                       = "CS_Attacker_Kali_Client_Access"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "50050"
    source_address_prefix      = "34.219.217.146/32"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "arto_cs_server_nic" {
  name                = "ARTO-CS-Server-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ARTO-CS-Server-NIC-Config"
    subnet_id                     = azurerm_subnet.arto_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.arto_cs_server_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "arto-isga-cs-server" {
  network_interface_id      = azurerm_network_interface.arto_cs_server_nic.id
  network_security_group_id = azurerm_network_security_group.arto_cs_server_nsg.id
}



# Create virtual machine
resource "azurerm_linux_virtual_machine" "cs-server-vm" {
  name                  = "ARTO-CS-Server"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.arto_cs_server_nic.id]
  size                  = "Standard_DS1_v2"
  #delete_os_disk_on_termination = true
  #delete_data_disks_on_termination = true


  os_disk {
    name                 = "ARTO-CS-Server-Disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"

  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "arto-cs-server"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.cs-server-key.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }

# Copy over sever setup script
  provisioner "file" {
      connection {
      agent       = false
      timeout     = "30m"
      host        = "${azurerm_linux_virtual_machine.cs-server-vm.public_ip_address}"
      user        = "${var.AZURE_USER}"
      private_key = "${tls_private_key.cs-server-key.private_key_pem}"
    }
      source = "server-setup.sh"
      destination = "/tmp/server-setup.sh"
  }

   # Copy script over to box to get ready for execution
  provisioner "file" {
      connection {
      agent       = false
      timeout     = "30m"
      host        = "${azurerm_linux_virtual_machine.cs-server-vm.public_ip_address}"
      user        = "${var.AZURE_USER}"
      private_key = "${tls_private_key.cs-server-key.private_key_pem}"
    }
      source = "cs-server-install.sh"
      destination = "/tmp/cs-server-install.sh"
  }

     # Copy script over to box to get ready for execution
  provisioner "file" {
      connection {
      agent       = false
      timeout     = "30m"
      host        = "${azurerm_linux_virtual_machine.cs-server-vm.public_ip_address}"
      user        = "${var.AZURE_USER}"
      private_key = "${tls_private_key.cs-server-key.private_key_pem}"
    }
      source = "cs.profile"
      destination = "/tmp/cs.profile"
  }

  # Copy additional SSH PUB key files
  provisioner "file" {
      connection {
      agent       = false
      timeout     = "30m"
      host        = "${azurerm_linux_virtual_machine.cs-server-vm.public_ip_address}"
      user        = "${var.AZURE_USER}"
      private_key = "${tls_private_key.cs-server-key.private_key_pem}"
    }
      source = "${aws_key_pair.kp.key_name}.pub"
      destination = "/tmp/${aws_key_pair.kp.key_name}.pub"
  }

      # Add custom SSH keys to root
    provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${azurerm_linux_virtual_machine.cs-server-vm.public_ip_address}"
      user        = "${var.AZURE_USER}"
      private_key = "${tls_private_key.cs-server-key.private_key_pem}"
    }
  
    
    inline = [
      "cat /tmp/CS-Server-Key-*.pub | sudo tee /root/.ssh/authorized_keys",
      "cat /tmp/ssh-keys.txt | sudo tee -a /root/.ssh/authorized_keys",
      "sudo service ssh reload",
      "sudo mkdir /opt/cobaltstrike",
      "echo U2FsdGVkX18gdacdpnFdN6Lc7ArCUgnJ6kYW1mm1j12aLf6PCPI5iXiaMyQBYO9A > lic.txt",
      "sudo cp /tmp/cs.profile /opt/cobaltstrike/cs.profile"
    ]
  
  } 

# Execute server-setup script
    provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${azurerm_linux_virtual_machine.cs-server-vm.public_ip_address}"
      user        = "${var.AZURE_USER}"
      private_key = "${tls_private_key.cs-server-key.private_key_pem}"
    }
  
    
    inline = [
      "chmod +x /tmp/server-setup.sh",
      "sudo /tmp/server-setup.sh"
    ]
  
  } 

# Execute script to install Cobalt Strike
    provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = "${azurerm_linux_virtual_machine.cs-server-vm.public_ip_address}"
      user        = "${var.AZURE_USER}"
      private_key = "${tls_private_key.cs-server-key.private_key_pem}"
    }
  
    
    inline = [
      "chmod +x /tmp/cs-server-install.sh",
      "sudo /tmp/cs-server-install.sh"
    ]
  
  } 


}