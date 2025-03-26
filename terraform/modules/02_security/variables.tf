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

variable "jenkins_subnet_id" {
  description = "ID of the subnet to associate with the jenkins security group"
  type        = string
}

variable "monitoring_subnet_id" {
  description = "ID of the subnet to associate with the monitoring security group"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access resources"
  type        = list(string)
}

variable "jenkins_subnet_prefix" {
  description = "The address prefix for the jenkins subnet"
  type        = string
}

variable "monitoring_subnet_prefix" {
  description = "The address prefix for the monitoring subnet"
  type        = string
}