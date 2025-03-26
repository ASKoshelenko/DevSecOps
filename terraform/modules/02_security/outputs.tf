output "jenkins_sg_id" {
  value = azurerm_network_security_group.jenkins_subnet_sg.id
}

output "monitoring_sg_id" {
  value = azurerm_network_security_group.monitoring_subnet_sg.id
}