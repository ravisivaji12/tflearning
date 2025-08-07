output "admin_password" {
  value     = module.DomainControllers.password
  sensitive = true
}

output "cc_resource_group" {
  value = local.domain_controller_parameters.cc_resource_group
}

output "cc_vnet" {
  value = local.domain_controller_parameters.cc_vnet
}

output "nsgs" {
  value = local.domain_controller_parameters.nsgs
}

output "route_tables" {
  value = local.domain_controller_parameters.route_tables
}

output "user_assigned_identities" {
  value = local.domain_controller_parameters.user_assigned_identities
}

output "keyvaults" {
  value = local.domain_controller_parameters.keyvaults
}

output "disk_encryption_sets" {
  value = local.domain_controller_parameters.disk_encryption_sets
}

output "virtual_machine_configs" {
  value = local.domain_controller_parameters.virtual_machine_configs
}

output "recovery_vault_config" {
  value = local.domain_controller_parameters.recovery_vault_config
}

output "log_analytics_workspace" {
  value = local.domain_controller_parameters.log_analytics_workspace
}

output "storage_account" {
  value = local.domain_controller_parameters.storage_account
}

output "NIC_subnet_key" {
  value = local.domain_controller_parameters.NIC_subnet_key
}

output "private_endpoint_subnet_key" {
  value = local.domain_controller_parameters.private_endpoint_subnet_key
}