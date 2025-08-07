terraform {
  backend "azurerm" {
    storage_account_name = "mfterraformstatesa"
    container_name       = "terraform-backend"
    key                  = "1129.tfstate"
    sas_token            = "?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2025-10-01T21:23:55Z&st=2024-10-01T13:23:55Z&spr=https,http&sig=1vp1bbRYbaln%2BNwvuppXcNglLWtKICwrQseSuEu3cTM%3D"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.27.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3.0"
    }
  }
}