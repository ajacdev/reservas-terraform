# Crear un grupo de recursos
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Crear el servidor PostgreSQL
resource "azurerm_postgresql_server" "example" {
  name                = "pg-server-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  administrator_login          = var.postgresql_admin_username
  administrator_login_password = var.postgresql_admin_password
  version                      = "11"
  sku_name                     = "B_Gen5_2"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  threat_detection_policy {
    email_account_admins = true
    state                = "Enabled"
  }
}

# Base de datos PostgreSQL
resource "azurerm_postgresql_database" "example" {
  name                = "example-db"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Crear una IP pública para la máquina virtual (NGINX)
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

# Subnet para la VM de NGINX
resource "azurerm_subnet" "example" {
  name                 = "subnet-example"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Crear interfaz de red para la VM de NGINX
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

# Crear la máquina virtual de NGINX
resource "azurerm_linux_virtual_machine" "example" {
  name                = "nginx-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  size                = var.nginx_vm_size

  admin_username = "adminuser"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = "nginxvm"
  admin_password = "Password1234!"  # Usa una clave segura.

  custom_data = <<-EOT
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOT

  tags = {
    environment = "dev"
  }
}