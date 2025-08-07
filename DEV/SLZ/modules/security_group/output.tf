output "security_group_resource" {
  value = azuread_group.group
}

output "security_group_object_id" {
  value = azuread_group.group.object_id
}