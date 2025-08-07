terraform {
  required_version = "1.12.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.21.1"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}