terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Если вам требуется бэкенд для состояния Terraform, раскомментируйте и настройте по необходимости
  # backend "azurerm" {
  #   resource_group_name  = "tfstate"
  #   storage_account_name = "tfstatenetflix"
  #   container_name       = "tfstate"
  #   key                  = "netflix-devsecops.tfstate"
  # }
}

provider "azurerm" {
  features {}
  # Если требуется указать конкретную подписку, используйте следующие параметры
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  # client_id       = var.azure_client_id
  # client_secret   = var.azure_client_secret
}

provider "time" {}
provider "tls" {}