resource "azurerm_mysql_flexible_server" "marathon_mysql" {
  name                   = "marathon-${var.project_name}-${var.environment}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password
  backup_retention_days  = var.mysql_retention_days
  delegated_subnet_id    = var.mysql_subnet_id  # For private connections
  private_dns_zone_id    = var.private_dns_zone_id  # For private connections
  sku_name               = var.mysql_sku_name
  version                = var.mysql_version
  zone = "3"

  depends_on = [
    var.mysql_subnet_id,
    var.private_dns_zone_id,
    var.private_dns_zone_vnet_link_id
  ]
}

resource "azurerm_mysql_flexible_database" "marathon_mysql" {
  name                = "${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.marathon_mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_0900_ai_ci"
}

resource "azurerm_mysql_flexible_server_configuration" "sql_generate_invisible_primary_key" {
  name                = "sql_generate_invisible_primary_key"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.marathon_mysql.name
  value               = "OFF"
}

resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.marathon_mysql.name
  value               = "OFF"
}

resource "azurerm_mysql_flexible_server_configuration" "event_scheduler" {
  name                = "event_scheduler"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.marathon_mysql.name
  value               = "OFF"
}