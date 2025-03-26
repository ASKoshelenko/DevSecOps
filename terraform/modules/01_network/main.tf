resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
}

resource "azurerm_virtual_network" "marathon_virtual_network" {
  name                = "vnet-${var.project_name}-${var.environment}"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

#####################
# Subnets
#####################

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "bastion-subnet-${var.project_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.marathon_virtual_network.name
  address_prefixes     = [var.bastion_subnet_address_prefix]
}

resource "azurerm_subnet" "monitoring_subnet" {
  name                 = "monitoring-subnet-${var.project_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.marathon_virtual_network.name
  address_prefixes     = [var.monitoring_subnet_address_prefix]
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet-${var.project_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.marathon_virtual_network.name
  address_prefixes     = [var.public_subnet_address_prefix]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet-${var.project_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.marathon_virtual_network.name
  address_prefixes     = [var.private_subnet_address_prefix]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "mysql_subnet" {
  name                 = "mysql-subnet-${var.project_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.marathon_virtual_network.name
  address_prefixes     = [var.mysql_subnet_address_prefix]
  service_endpoints    = ["Microsoft.Storage"]
  
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

#####################
# Public IP's and DNS
#####################

resource "azurerm_public_ip" "public_ips" {
  for_each            = var.create_public_ips
  name                = "pip-${each.key}-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "mysqldnslink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.marathon_virtual_network.id
  registration_enabled  = false
}