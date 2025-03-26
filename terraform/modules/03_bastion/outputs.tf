output "bastion_private_ip" {
  value = azurerm_network_interface.bastion_nic.private_ip_address
}