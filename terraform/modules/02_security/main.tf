#########################
# Security groups
#########################

resource "azurerm_network_security_group" "jenkins_subnet_sg" {
  name                = "jenkins-nsg-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "monitoring_subnet_sg" {
  name                = "monitoring-nsg-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

#########################
# Jenkins sg rules
#########################

resource "azurerm_network_security_rule" "allow_ssh_to_jenkins" {
  name                        = "AllowSSHToJenkins"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.allowed_ip_ranges
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.jenkins_subnet_sg.name
}

resource "azurerm_network_security_rule" "allow_jenkins_web" {
  name                        = "AllowJenkinsWeb"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefixes     = var.allowed_ip_ranges
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.jenkins_subnet_sg.name
}

resource "azurerm_network_security_rule" "allow_sonarqube" {
  name                        = "AllowSonarQube"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9000"
  source_address_prefixes     = var.allowed_ip_ranges
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.jenkins_subnet_sg.name
}

resource "azurerm_network_security_rule" "allow_netflix_web" {
  name                        = "AllowNetflixApp"
  priority                    = 1004
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8081"
  source_address_prefixes     = var.allowed_ip_ranges
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.jenkins_subnet_sg.name
}

#########################
# Monitoring sg rules
#########################

resource "azurerm_network_security_rule" "allow_ssh_to_monitoring" {
  name                        = "AllowSSHToMonitoring"
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

resource "azurerm_network_security_rule" "allow_grafana" {
  name                        = "AllowGrafana"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefixes     = var.allowed_ip_ranges
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.monitoring_subnet_sg.name
}

resource "azurerm_network_security_rule" "allow_prometheus" {
  name                        = "AllowPrometheus"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9090"
  source_address_prefixes     = var.allowed_ip_ranges
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.monitoring_subnet_sg.name
}

resource "azurerm_network_security_rule" "allow_node_exporter" {
  name                        = "AllowNodeExporter"
  priority                    = 1004
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9100"
  source_address_prefixes     = concat(var.allowed_ip_ranges, [var.jenkins_subnet_prefix])
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.monitoring_subnet_sg.name
}

#########################
# Subnet associations
#########################

resource "azurerm_subnet_network_security_group_association" "jenkins_subnet_sg_assoc" {
  subnet_id                 = var.jenkins_subnet_id
  network_security_group_id = azurerm_network_security_group.jenkins_subnet_sg.id
}

resource "azurerm_subnet_network_security_group_association" "monitoring_subnet_sg_assoc" {
  subnet_id                 = var.monitoring_subnet_id
  network_security_group_id = azurerm_network_security_group.monitoring_subnet_sg.id
}