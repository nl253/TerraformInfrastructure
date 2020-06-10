provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you are using version 1.x, the "features" block is not allowed.
  version = "=2.0"
  features {}
}

provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

locals {
  network_interface_name = "${var.app_name}-vm-network-interface"
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${var.app_name}resourcegroup"
  tags     = local.tags
}

module "networking" {
  source         = "../azure-networking"
  resource_group = azurerm_resource_group.rg.name
  public_subnet_network_security_rules = [
    {
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_port_range     = "3389"
      destination_address_prefix = "*"
    }
  ]
  app_name = var.app_name
  env      = var.env
  location = var.location
}

resource "azurerm_public_ip" "ip" {
  location            = var.location
  name                = "${var.app_name}-vm-network-interface-ip-public"
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "aws_route53_record" "route53_record" {
  name    = "${var.app_name}-dns-record"
  type    = "A"
  ttl     = "300"
  zone_id = var.route53_zone_id
  records = [azurerm_public_ip.ip.ip_address]
}

resource "azurerm_network_interface" "network_interface" {
  location            = var.location
  name                = local.network_interface_name
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "${local.network_interface_name}-ip"
    subnet_id                     = module.networking.subnets[0].id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.tags
}

resource "azurerm_managed_disk" "disk" {
  name                 = "${var.app_name}-disk"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "25"
  tags                 = local.tags
}

resource "azurerm_image" "image" {
  location            = var.location
  name                = "${var.app_name}-image"
  resource_group_name = azurerm_resource_group.rg.name
  os_disk {
    managed_disk_id = azurerm_managed_disk.disk.id
  }
  tags = local.tags
}

resource "azurerm_windows_virtual_machine" "vm" {
  location              = var.location
  name                  = "${var.app_name}-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  size                  = var.vm_size
  source_image_id       = azurerm_image.image.id
  additional_capabilities {
    ultra_ssd_enabled = false
  }
  enable_automatic_updates = true
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  admin_username = "adminuser"
  admin_password = "P@$$w0rd1234!"
  tags           = local.tags
}
