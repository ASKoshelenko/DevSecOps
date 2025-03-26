
output "app_service_name" {
  value = azurerm_linux_web_app.python_app.name
}

output "app_service_default_hostname" {
  value = azurerm_linux_web_app.python_app.default_hostname
}

output "app_service_id" {
  value = azurerm_linux_web_app.python_app.id
}

output "app_service_plan_id" {
  value = azurerm_service_plan.python_plan.id
}

output "app_service_outbound_ip_addresses" {
  value       = azurerm_linux_web_app.python_app.outbound_ip_addresses
  description = "The outbound IP addresses of the App Service"
}


