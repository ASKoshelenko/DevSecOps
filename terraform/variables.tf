variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "North Europe"
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

variable "jenkins_subnet_prefix" {
  description = "Address prefix for the Jenkins subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "monitoring_subnet_prefix" {
  description = "Address prefix for the monitoring subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "create_public_ips" {
  description = "Map of public IPs to create"
  type = map(object({
    allocation_method = string
    sku               = string
  }))
  default = {
    "jenkins" = {
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
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

variable "storage_config" {
  description = "Configuration for storage account"
  type = object({
    account_tier             = string
    account_replication_type = string
    container_name           = string
  })
}

variable "grafana_password" {
  description = "Password for Grafana admin user"
  type        = string
  sensitive   = true
}

variable "grafana_user" {
  description = "Username for Grafana admin user"
  type        = string
  default     = "admin"
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
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

variable "tmdb_api_key" {
  description = "API Key for TMDB"
  type        = string
  sensitive   = true
  default     = "c9cbf23e56e7f8dad215a3a7a3758244"
}

variable "ssl_certificate_password" {
  description = "Password for SSL certificate"
  type        = string
  sensitive   = true
}

variable "enable_http2" {
  description = "Enable HTTP2"
  type        = bool
  default     = true
}

variable "data_location" {
  description = "The location where data is stored"
  type        = string
  default     = "United States"
}

variable "infinity_client_id" {
  description = "Client ID for Infinity"
  type        = string
}

variable "infinity_client_secret" {
  description = "Client Secret for Infinity"
  type        = string
  sensitive   = true
}