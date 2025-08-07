# #############################################################################
# #                           Azure Providers
# #############################################################################

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azuread = {
      source                = "hashicorp/azuread"
      configuration_aliases = [azuread.azuread_mccaingroup_onmicrosoft_com]
    }
  }
}
