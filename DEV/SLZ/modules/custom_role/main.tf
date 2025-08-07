resource "random_uuid" "role_id" {
}

resource "azurerm_role_definition" "customerole" {
  role_definition_id = random_uuid.role_id.result
  provider           = azurerm.azurerm_application_provider
  name               = var.role_name
  scope              = var.role_definition_location_resource_id
  description        = var.description

  permissions {
    actions     = var.actions
    not_actions = []
  }

  assignable_scopes = values(var.assignable_scopes)
}