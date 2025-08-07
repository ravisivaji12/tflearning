
output "application_id" {
  value = azuread_application.app.id
}

output "client_secret" {
  value     = azuread_application_password.app_password.value
  sensitive = true
}

output "principal_id" {
  value = azuread_service_principal.spn.id
}
