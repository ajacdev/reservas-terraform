# Crear un grupo de recursos
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Crear una IP pública para la máquina virtual (NGINX y PostgreSQL)
resource "azurerm_public_ip" "example" {
  name                = "nginx-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

# Crear la red virtual
resource "azurerm_virtual_network" "example" {
  name                = "vnet-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet para la VM
resource "azurerm_subnet" "example" {
  name                 = "subnet-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Crear interfaz de red para la VM
resource "azurerm_network_interface" "example" {
  name                = "nic-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

# Crear la máquina virtual con NGINX y PostgreSQL
resource "azurerm_linux_virtual_machine" "example" {
  name                = "nginx-postgres-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size                = var.nginx_vm_size

  admin_username = var.admin_username
  admin_password = var.admin_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"  # Incluido en la capa gratuita
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name = "nginxvm"

  # Instalar NGINX y PostgreSQL en la VM
  custom_data = <<-EOT
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx postgresql postgresql-contrib
              sudo systemctl start nginx
              sudo systemctl enable nginx
              sudo systemctl start postgresql
              sudo systemctl enable postgresql
              sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${var.admin_password}';"
              EOT

  tags = {
    environment = "dev"
  }
}
