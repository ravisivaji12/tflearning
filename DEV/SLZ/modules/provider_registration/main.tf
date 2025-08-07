resource "azurerm_resource_provider_registration" "provider_registration" {
  provider = azurerm.azurerm_application_provider
  for_each = var.providers_to_be_registered != null ? toset(var.providers_to_be_registered) : toset([])
  name     = each.value

  lifecycle {
    prevent_destroy = true
  }
}