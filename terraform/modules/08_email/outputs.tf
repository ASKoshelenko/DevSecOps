output "smtp_server" {
  value       = "smtp.azurecomm.net"
  description = "SMTP server for Azure Communication Services"
}

output "smtp_port" {
  value       = 587
  description = "SMTP port for Azure Communication Services"
}

output "smtp_username" {
  value       = "${azurerm_communication_service.marathon_communication_service.name}.${azuread_application.smtp_auth_app.client_id}.${data.azurerm_client_config.current.tenant_id}"
  description = "SMTP username for Azure Communication Services"
}

output "smtp_password" {
  value       = azuread_application_password.smtp_auth_secret.value
  description = "SMTP password for Azure Communication Services"
  sensitive   = true
}

output "email_service_domain" {
  value       = azurerm_email_communication_service_domain.marathon_email_communication_service_domain.name
  description = "The domain of the Email Communication Service"
}

output "email_sender_domain" {
  value       = azurerm_email_communication_service_domain.marathon_email_communication_service_domain.from_sender_domain
  description = "The sender domain for the Email Communication Service"
}

# output "communication_service_primary_access_key" {
#   value     = azurerm_communication_service.marathon_communication_service.primary_key
#   sensitive = true
# }

# output "communication_service_secondary_access_key" {
#   value     = azurerm_communication_service.marathon_communication_service.secondary_key
#   sensitive = true
# }

output "communication_service_primary_connection_string" {
   value     = azurerm_communication_service.marathon_communication_service.primary_connection_string
   sensitive = true
}

# output "communication_service_secondary_connection_string" {
#   value     = azurerm_communication_service.marathon_communication_service.secondary_connection_string
#   sensitive = true
# }


