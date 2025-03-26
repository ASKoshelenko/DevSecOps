variable "grafana_user" {
  description = "Password for Grafana admin user"
  type        = string
}

variable "grafana_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_public_ip" {
  type        = string
  description = "The IP address for the URL link of your Grafana instance"
}

variable "infinity_client_id" {
  type = string
}

variable "azure_tenant_id" {
  type = string
}

variable "infinity_client_secret" {
  type = string
  sensitive = true
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

