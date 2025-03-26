output "monitoring_vm_id" {
  value = azurerm_linux_virtual_machine.monitoring_vm.id
}

output "monitoring_private_ip" {
  value = azurerm_network_interface.monitoring_nic.private_ip_address
}