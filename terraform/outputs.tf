output "resource_group_name" {
  value = module.network.resource_group_name
}

output "vnet_id" {
  value = module.network.vnet_id
}

# output "monitoring_vm_public_ip" {
#   value = module.monitoring.grafana_public_ip
# }

data "azurerm_public_ip" "monitoring" {
  name                = "pip-monitoring-${var.project_name}-${var.environment}"
  resource_group_name = module.network.resource_group_name
  depends_on          = [module.monitoring]
}

output "monitoring_vm_public_ip" {
  value = module.network.public_ip_addresses["monitoring"]
}

output "mysql_subnet_id" {
  value = module.network.mysql_subnet_id
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "mysql_server_fqdn" {
  value = module.database.mysql_server_fqdn
}

# output "monitoring_vm_private_ip" {
#   value = module.monitoring.monitoring_vm_private_ip
# }

# output "app_service_name" {
#   value = module.app_dotnet.app_service_name
# }

# output "app_service_default_hostname" {
#   value = module.app_dotnet.app_service_default_hostname
# }

# output "app_gateway_public_ip" {
#   value = module.app_dotnet.app_gateway_public_ip
# }

#################################################
###  EMAIL OUTPUTS
#################################################

output "smtp_server" {
  value = module.email.smtp_server
}

output "smtp_port" {
  value = module.email.smtp_port
}

output "smtp_username" {
  value = module.email.smtp_username
}

output "smtp_password" {
  value     = module.email.smtp_password
  sensitive = true
}

output "email_service_domain" {
  value = module.email.email_service_domain
}

output "email_sender_domain" {
  value       = module.email.email_sender_domain
  description = "The sender domain for the Email Communication Service"
}