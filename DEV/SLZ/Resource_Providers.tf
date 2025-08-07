#############################################################################
#                           Azure Providers
#############################################################################

#               McCain MF-MD-NonProd Subscription

provider "azurerm" {
  alias           = "azurerm_application_provider_sandbox"
  subscription_id = var.application_subscription_id_sandbox
  features {}
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}

provider "azurerm" {
  alias           = "azurerm_application_provider_dev"
  subscription_id = var.application_subscription_id_dev
  features {}
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}

provider "azurerm" {
  alias           = "azurerm_application_provider_preprod"
  subscription_id = var.application_subscription_id_preprod
  features {}
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}

provider "azurerm" {
  alias           = "azurerm_application_provider_prod"
  subscription_id = var.application_subscription_id_prod
  features {}
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}

#               McCain MF-Core-Infrastructure-Prod Subscription

provider "azurerm" {
  alias           = "azurerm_core_infrastructure_provider"
  subscription_id = var.core_infrastructure_subscription_id
  features {}
  resource_provider_registrations = "none"
}

#                         mccaingroup.onmicrosoft.com Azure AD

provider "azuread" {
  alias         = "azuread_mccaingroup_onmicrosoft_com"
  client_id     = var.MF_AAD_client_id
  client_secret = var.MF_CI_AAD_CS
}