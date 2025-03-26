variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "North Europe"
}

variable "data_location" {
  description = "The location where the Email Communication service stores its data at rest. Possible values are Africa, Asia Pacific, Australia, Brazil, Canada, Europe, France, Germany, India, Japan, Korea, Norway, Switzerland, UAE, UK and United States. Changing this forces a new Email Communication Service to be created."
  type        = string
  default     = "Europe"
}

variable "project_name" {
  description = "Name of the project, used in resource names"
  type        = string
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_address_prefix" {
  description = "Address prefix for the services subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "private_subnet_address_prefix" {
  description = "Address prefix for the services subnet"
  type        = string
  default     = "10.0.5.0/24"
}

variable "bastion_subnet_address_prefix" {
  description = "Address prefix for the services subnet"
  type        = string
  default     = "10.0.6.0/24"
}

variable "monitoring_subnet_address_prefix" {
  description = "Address prefix for the services subnet"
  type        = string
  default     = "10.0.7.0/24"
}

variable "mysql_subnet_address_prefix" {
  description = "Address prefix for the MySQL subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "route_table_name" {
  description = "Name of the route table"
  type        = string
  default     = "main-route-table"
}

variable "public_routes" {
  description = "List of routes to be added to the route table"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = string
  }))
  default = []
}

variable "private_routes" {
  description = "List of routes to be added to the route table"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = string
  }))
  default = []
}

variable "create_public_ips" {
  description = "Map of public IPs to create"
  type = map(object({
    allocation_method = string
    sku               = string
  }))
  default = {
    "bastion" = {
      allocation_method = "Dynamic"
      sku               = "Basic"
    }
    "monitoring" = {
      allocation_method = "Dynamic"
      sku               = "Basic"
    }
  }
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access resources"
  type        = list(string)
}

variable "vm_config" {
  description = "Configuration for the VM"
  type = object({
    size           = string
    admin_username = string
  })
  default = {
    size           = "Standard_B1s"
    admin_username = "azureuser"
  }
}

variable "admin_ssh_keys" {
  description = "List of public SSH keys for VM access"
  type        = list(string)
}

variable "vm_os_disk_config" {
  description = "OS disk configuration for VMs"
  type = object({
    caching              = string
    storage_account_type = string
  })
  default = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

variable "vm_source_image_reference" {
  description = "Source image reference for VMs"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }
}

variable "mysql_config" {
  description = "Configuration for MySQL"
  type = object({
    admin_username = string
    admin_password = string
    sku_name       = string
    version        = string
  })
  sensitive = true
}

variable "mysql_retention_days" {
  description = "Database backups keeping days"
  type        = string
}

variable "storage_config" {
  description = "Configuration for storage account"
  type = object({
    account_tier             = string
    account_replication_type = string
    container_name           = string
  })
  default = {
    account_tier             = "Standard"
    account_replication_type = "LRS"
    container_name           = "mycontainer"
  }
}

variable "private_dns_zone_vnet_link_id" {
  description = "The ID of the Private DNS Zone VNet Link"
  type        = string
  default     = null
}

variable "ssl_certificate_password" {
  description = "Password for the SSL certificate"
  type        = string
  sensitive   = true
}

variable "enable_http2" {
  description = "Enable HTTP2 for the Application Gateway"
  type        = bool
  default     = true
}

variable "grafana_url" {
  description = "Grafana URL"
  type        = string
  default     = ""  # This allows it to be empty initially
}

variable "grafana_user" {
  description = "Password for Grafana admin user"
  type        = string

}

variable "grafana_password" {
  description = "Password for Grafana admin user"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "azure_client_secret" {
  description = "Azure Client Secret"
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "infinity_client_id" {
  description = "Client_id in the section Application Registration (in section Subscription) for allow access infinity plugin through datasource"
  type        = string
}

variable "infinity_client_secret" {
  description = "Client_secret in the section Application Registration (in section Subscription) for allow access infinity plugin through datasource"
  type        = string
}
