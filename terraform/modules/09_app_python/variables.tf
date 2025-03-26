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
  description = "ID of the subnet to integrate with App gateway"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the subnet to integrate with App Service"
  type        = string
}

variable "enable_http2" {
  description = "Enable HTTP2 for the Application Gateway"
  type        = bool
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access resources directly"
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

variable "storage_account_connection_string" {
  description = "Storage account access key"
  type        = string
  sensitive   = true
}

variable "mysql_server_name" {
  description = "Name of the MySQL Flexible Server"
  type        = string
}

variable "mysql_admin_username" {
  description = "The administrator username of the MySQL server"
  type        = string
}

variable "mysql_admin_password" {
  description = "The administrator password of the MySQL server"
  type        = string
  sensitive   = true
}

variable "smtp_server" {
  description = "SMTP server address"
  type        = string
}

variable "smtp_port" {
  description = "SMTP server port"
  type        = number
}

variable "smtp_username" {
  description = "SMTP username"
  type        = string
}

variable "smtp_password" {
  description = "SMTP password"
  type        = string
  sensitive   = true
}

variable "email_connection_string" {
  description = "Communication service connection string"
  type = string
  sensitive = false
}