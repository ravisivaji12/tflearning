output "role_definition_resource_id" {
  value = azurerm_role_definition.customerole.role_definition_resource_id
}

output "role_id" {
  value = random_uuid.role_id.result
}