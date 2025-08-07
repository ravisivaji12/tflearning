#############################################################################
#                           Azure Providers
#############################################################################

terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      configuration_aliases = [
        azuread.azuread_mccaingroup_onmicrosoft_com
      ]
    }
  }
}


