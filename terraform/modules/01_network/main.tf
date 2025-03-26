resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project_name}-${var.environment}"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

#####################
# Subnets
#####################

resource "azurerm_subnet" "jenkins_subnet" {
  name                 = "jenkins-subnet-${var.project_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.jenkins_subnet_prefix]
}

resource "azurerm_subnet" "monitoring_subnet" {
  name                 = "monitoring-subnet-${var.project_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.monitoring_subnet_prefix]
}

#####################
# Public IP's
#####################

resource "azurerm_public_ip" "public_ips" {
  for_each            = var.create_public_ips
  name                = "pip-${each.key}-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
}