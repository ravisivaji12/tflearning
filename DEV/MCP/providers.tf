terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  resource_provider_registrations = "none"
  subscription_id                 = var.cfg_core_infrastructure_subscription_id
  storage_use_azuread             = true
  use_cli                         = false
  use_msi                         = false
  use_oidc                        = false
}

provider "azuread" {
  client_id     = var.cfg_aad_client_id
  client_secret = var.cfg_aad_client_secret
  tenant_id     = var.cfg_tenant_id
  use_cli       = false
  use_msi       = false
  use_oidc      = false
}

provider "azapi" {
  use_cli  = false
  use_msi  = false
  use_oidc = false
}