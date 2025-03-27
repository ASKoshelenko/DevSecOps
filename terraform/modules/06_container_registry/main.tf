resource "azurerm_container_registry" "acr" {
  name                = "acr${var.project_name}${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # network_rule_set {
  #   default_action = "Allow"
  #   ip_rule {
  #     action   = "Allow"
  #     ip_range = "0.0.0.0/0"
  #   }
  # }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}