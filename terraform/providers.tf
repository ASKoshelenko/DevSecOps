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
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.7.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = "~> 0.2.5"
    }
  }
  # Uncomment this block if you want to use Azure Storage Account for Terraform State
  # backend "azurerm" {
  #   resource_group_name  = "tfstate"
  #   storage_account_name = "tfstatemarathon"
  #   container_name       = "tfstatemarathon"
  #   key                  = "marathon.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

provider "time" {}

# This provider will be used after Grafana is set up
provider "grafana" {
  alias = "configured"
  url   = coalesce(var.grafana_url, "https://${local.grafana_public_ip}")
  auth  = "${var.grafana_user}:${var.grafana_password}"
  insecure_skip_verify = true
  retries              = 3
  retry_wait           = 60
}
provider "tls" {}

provider "pkcs12" {}
