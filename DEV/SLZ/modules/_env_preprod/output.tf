output "monitoring_tools_vnet_name" {
  value = module.virtual_network-tools.name
}

output "monitoring_tools_vnet_resource_id" {
  value = module.virtual_network-tools.resource_id
}

output "monitoring_tools_dr_vnet_name" {
  value = module.virtual_network-tools-ce.name
}

output "monitoring_tools_dr_vnet_resource_id" {
  value = module.virtual_network-tools-ce.resource_id
}

output "binaries_storage_account_name" {
  value = module.storage_account-binaries.name
}

output "binaries_storage_account_id" {
  value = module.storage_account-binaries.resource_id
}

output "cluster_role_definition_resource_id" {
  value = module.custom_role-clustering.role_definition_resource_id
}

output "cluster_role_id" {
  value = module.custom_role-clustering.role_id
}

output "fileshare_storage_account_name" {
  value = module.storage_account-fileshare.name
}

output "fileshare_storage_account_id" {
  value = module.storage_account-fileshare.resource_id
}