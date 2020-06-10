locals {
  subnet_names                     = ["public", "private"]
  subnet_cidrs                     = [var.public_subnet, var.private_subnet]
  network_security_group_names     = ["public", "private"]
  application_security_group_names = ["public", "private"]
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "azurerm_virtual_network" "network" {
  address_space       = var.address_space
  location            = var.location
  name                = "${var.app_name}-vnet"
  resource_group_name = var.resource_group
  tags                = local.tags
}

resource "azurerm_subnet" "subnets" {
  name                 = "${azurerm_virtual_network.network.name}-subnet-${local.subnet_names[count.index]}"
  resource_group_name  = var.resource_group
  address_prefix       = local.subnet_cidrs[count.index]
  virtual_network_name = azurerm_virtual_network.network.name
  count                = length(local.subnet_cidrs)
}

resource "azurerm_network_security_group" "network_security_groups" {
  location            = var.location
  name                = "${azurerm_subnet.subnets[count.index].name}-network-security-group-${local.network_security_group_names[count.index]}"
  resource_group_name = var.resource_group
  tags                = local.tags
  count               = length(local.network_security_group_names)
}

resource "azurerm_subnet_network_security_group_association" "network_security_group_public_association" {
  network_security_group_id = azurerm_network_security_group.network_security_groups[count.index].id
  subnet_id                 = azurerm_subnet.subnets[count.index].id
  count                     = length(azurerm_subnet.subnets)
}


resource "azurerm_network_security_rule" "network_security_rule_allow_external_traffic" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "${azurerm_network_security_group.network_security_groups[0].name}-allow-external-traffic-rule"
  description                 = "Allow all TCP traffic to ${azurerm_subnet.subnets[0].name} subnet in ${azurerm_virtual_network.network.name} VNet."
  network_security_group_name = azurerm_network_security_group.network_security_groups[0].name
  priority                    = 4096
  resource_group_name         = var.resource_group
  protocol                    = "tcp"
  source_address_prefix       = var.public_subnet_network_security_rules[count.index].source_address_prefix
  source_port_range           = var.public_subnet_network_security_rules[count.index].source_port_range
  destination_port_range      = var.public_subnet_network_security_rules[count.index].destination_port_range
  destination_address_prefix  = var.public_subnet_network_security_rules[count.index].destination_address_prefix
  count                       = length(var.public_subnet_network_security_rules)
}

resource "azurerm_network_ddos_protection_plan" "ddos_protection_plan" {
  name                = "${var.app_name}-ddos-protection-plan"
  resource_group_name = var.resource_group
  location            = var.location
  tags                = local.tags
}
