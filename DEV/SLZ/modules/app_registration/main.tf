resource "azuread_application" "app" {
  provider     = azuread.azuread_mccaingroup_onmicrosoft_com
  display_name = var.app_registration_name
}

resource "azuread_application_password" "app_password" {
  provider       = azuread.azuread_mccaingroup_onmicrosoft_com
  application_id = azuread_application.app.id
  display_name   = "terraform-generated-secret"
}

resource "azuread_service_principal" "spn" {
  provider  = azuread.azuread_mccaingroup_onmicrosoft_com
  client_id = azuread_application.app.id
}

