# #############################################################################
# #                           Azure Providers
# #############################################################################

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      configuration_aliases = [
        azurerm.azurerm_application_provider
      ]
    }

  }
}
