variable "project_name" {
  description = "Name of the project, used in resource names"
  type        = string
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "jenkins_subnet_prefix" {
  description = "Address prefix for the jenkins subnet"
  type        = string
}

variable "monitoring_subnet_prefix" {
  description = "Address prefix for the monitoring subnet"
  type        = string
}

variable "create_public_ips" {
  description = "Map of public IPs to create"
  type = map(object({
    allocation_method = string
    sku               = string
  }))
  default = {}
}