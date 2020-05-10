provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you are using version 1.x, the "features" block is not allowed.
  version = "=2.0"
  features {}
}

resource "azurerm_resource_group" "rg" {
  location = var.region
  name     = "${var.app_name}-resource-group"
}

resource "azurerm_windows_virtual_machine" "vm" {
  location              = var.region
  name                  = "${var.app_name}-vm"
  network_interface_ids = []
  resource_group_name   = azurerm_resource_group.rg.name
  vm_size               = var.vm_size
  admin_username        = "adminuser"
  admin_password        = "P@$$w0rd1234!"
}
