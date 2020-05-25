provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you are using version 1.x, the "features" block is not allowed.
  version = "=2.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  location = var.region
  name     = "${var.app_name}resourcegroup"
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  name                = "${var.app_name}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  subnet {
    address_prefix = "10.0.0.0/24"
    name           = "${var.app_name}-subnet-public"
    security_group = azurerm_network_security_group.security_group.id
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "azurerm_network_security_group" "security_group" {
  location            = var.region
  name                = "${var.app_name}-security-group"
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "${var.app_name}-rule-allow-rdp"
    priority                   = 100
    protocol                   = "Tcp"
    destination_port_range     = "*"
    destination_address_prefix = "*"
    source_address_prefix      = "*"
    source_port_range          = "3389"
  }
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "azurerm_public_ip" "ip" {
  location            = var.region
  name                = "${var.app_name}-vm-network-interface-ip-public"
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_interface" "network_interface" {
  location            = var.region
  name                = "${var.app_name}-vm-network-interface"
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "${var.app_name}-vm-network-interface-ip"
    subnet_id                     = element(tolist(azurerm_virtual_network.vnet.subnet), 0).id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  location              = var.region
  name                  = "${var.app_name}-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  size                  = var.vm_size
  source_image_id       = "a7870b4e-624b-4ab0-a7a9-f187b6aecb4c"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  admin_username = "adminuser"
  admin_password = "P@$$w0rd1234!"
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}
