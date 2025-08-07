terraform {
  required_version = "1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.13"
    }
  }
}
provider "azurerm" {
  features {
  }
  subscription_id = "855f9502-3230-4377-82a2-cc5c8fa3c59d"
}