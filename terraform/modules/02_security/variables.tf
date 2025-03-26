variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "project_name" {
  description = "Name of the project, used in resource names"
  type        = string
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the services subnet to associate with the public"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the services subnet to associate with the private"
  type        = string
}

variable "bastion_subnet_id" {
  description = "ID of the services subnet to associate with the bastion"
  type        = string
}
variable "monitoring_subnet_id" {
  description = "ID of the services subnet to associate with the bastion"
  type        = string
}

variable "mysql_subnet_id" {
  description = "ID of the services subnet to associate with the mysql"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access resources"
  type        = list(string)
}

variable "public_subnet_address_prefix" {
  description = "The address prefix for the public subnet"
  type        = string
}

variable "private_subnet_address_prefix" {
  description = "The address prefix for the private subnet"
  type        = string
}