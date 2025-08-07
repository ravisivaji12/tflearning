output "private_endpoint_resource" {
  value = azurerm_private_endpoint.private_endpoint
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.private_endpoint.id
}