#########################
# Security groups
#########################

resource "azurerm_network_security_group" "bastion_subnet_sg" {
  name                = "bastion-services-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "monitoring_subnet_sg" {
  name                = "monitoring-services-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "public_subnet_sg" {
  name                = "dotnet-lb-services-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "private_subnet_sg" {
  name                = "dotnet-app-services-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "mysql_subnet_sg" {
  name                = "mysql-services-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

#########################
# bastion sg rules
#########################

resource "azurerm_network_security_rule" "allow_ssh_from_internet" {
  name                        = "AllowSSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.allowed_ip_ranges
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.bastion_subnet_sg.name
}

#########################
# monitoring sg rules
#########################

resource "azurerm_network_security_rule" "allow_ssh_from_internet_monitoring" {
  name                        = "AllowSSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.allowed_ip_ranges
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.monitoring_subnet_sg.name
}

# New rule for HTTP
resource "azurerm_network_security_rule" "allow_http_from_internet_monitoring" {
  name                        = "AllowHTTP"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefixes       = var.allowed_ip_ranges
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.monitoring_subnet_sg.name
}

# New rule for HTTPS
resource "azurerm_network_security_rule" "allow_https_from_internet_monitoring" {
  name                        = "AllowHTTPS"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefixes       = var.allowed_ip_ranges
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.monitoring_subnet_sg.name
}

#########################
# public subnet sg rules
#########################

resource "azurerm_network_security_rule" "allow_http_https_from_allowed_ips" {
  name                        = "AllowHTTPandHTTPSFromAllowedIPs"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefixes     = var.allowed_ip_ranges
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public_subnet_sg.name
}

#########################
# private subnet sg rules
#########################

resource "azurerm_network_security_rule" "deny_direct_access_to_app" {
  name                        = "DenyDirectAccessToApp"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = var.private_subnet_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.private_subnet_sg.name
}

resource "azurerm_network_security_rule" "allow_gateway_to_app" {
  name                        = "AllowGatewayToApp"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.public_subnet_address_prefix
  destination_address_prefix  = var.private_subnet_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.private_subnet_sg.name
}

#########################
# subnet associations
#########################

resource "azurerm_subnet_network_security_group_association" "public_subnet_sg_assoc" {
  subnet_id                 = var.public_subnet_id
  network_security_group_id = azurerm_network_security_group.public_subnet_sg.id
}

resource "azurerm_subnet_network_security_group_association" "private_subnet_sg_assoc" {
  subnet_id                 = var.private_subnet_id
  network_security_group_id = azurerm_network_security_group.private_subnet_sg.id
}

resource "azurerm_subnet_network_security_group_association" "bastion_subnet_sg_assoc" {
  subnet_id                 = var.bastion_subnet_id
  network_security_group_id = azurerm_network_security_group.bastion_subnet_sg.id
}

resource "azurerm_subnet_network_security_group_association" "monitoring_subnet_sg_assoc" {
  subnet_id                 = var.monitoring_subnet_id
  network_security_group_id = azurerm_network_security_group.monitoring_subnet_sg.id
}

resource "azurerm_subnet_network_security_group_association" "mysql_subnet_sg_assoc" {
  subnet_id                 = var.mysql_subnet_id
  network_security_group_id = azurerm_network_security_group.mysql_subnet_sg.id
}