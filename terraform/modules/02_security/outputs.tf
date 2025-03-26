output "public_sg_id" {
  value = azurerm_network_security_group.public_subnet_sg.id
}

output "private_sg_id" {
  value = azurerm_network_security_group.private_subnet_sg.id
}