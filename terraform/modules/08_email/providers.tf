terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    # https://github.com/hashicorp/terraform-provider-azurerm/issues/24444
  }
}