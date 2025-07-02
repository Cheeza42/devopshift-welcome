provider "azurerm" {
  features {}
}
provider "time" {
  
}
resource "azurerm_resource_group" "rg-ALONALBA" {
  name     = "ALONALBA-resources"
  location = var.location
}

resource "azurerm_virtual_network" "vnet-ALONALBA" {
  name                = "ALONALBA-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-ALONALBA.name
}

resource "azurerm_subnet" "subnet-ALONALBA" {
  name                 = "ALONALBA-subnet"
  resource_group_name  = azurerm_resource_group.rg-ALONALBA.name
  virtual_network_name = azurerm_virtual_network.vnet-ALONALBA.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip-ALONALBA" {
  name                = "ALONALBA-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-ALONALBA.name
  allocation_method   = "Dynamic"  # Dynamic IP allocation for Basic SKU
  sku = "Basic"  
}


resource "azurerm_network_interface" "nic-ALONALBA" {
  name                = "ALONALBA-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-ALONALBA.name

  ip_configuration {
    name                          = "ALONALBA-ipconfig"
    subnet_id                     = azurerm_subnet.subnet-ALONALBA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-ALONALBA.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-ALONALBA" {
  name                  = "ALONALBA-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg-ALONALBA.name
  network_interface_ids = [azurerm_network_interface.nic-ALONALBA.id]
  size                  = var.vm_size

  os_disk {
    name              = "ALONALBA-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name = "ALONALBA-vm"
}

resource "time_sleep" "wait_for_ip" {
  create_duration = "120s"  # Wait for 30 seconds
}

resource "null_resource" "check_public_id" {
  provisioner "local-exec" {
        command = <<EOT
       if [ -z "${azurerm_public_ip.pip-ALONALBA.ip_address}" ]; then
     echo "ERROR: Public IP address was not assigned." >&2
     exit 1
   fi
  EOT
  }        
 depends_on = [azurerm_public_ip.pip-ALONALBA, time_sleep.wait_for_ip]
    
  
}