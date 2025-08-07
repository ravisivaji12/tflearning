# #############################################################################
# #                           Azure Providers
# #############################################################################

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      configuration_aliases = [
        azurerm.azurerm_core_infrastructure_provider
      ]
    }
    azuread = {
      source = "hashicorp/azuread"
      configuration_aliases = [
        azuread.azuread_mccaingroup_onmicrosoft_com
      ]
    }
  }
}
