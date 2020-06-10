output "network" {
  value = azurerm_virtual_network.network
}

output "subnets" {
  value = azurerm_subnet.subnets
}

output "security_groups" {
  value = azurerm_network_security_group.network_security_groups
}

