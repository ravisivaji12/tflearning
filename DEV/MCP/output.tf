output "domain_controller_passwords" {
  value = {
    for k, mod in module.regional_platform_infrastructure :
    k => {
      region   = k
      password = mod.admin_password
    }
  }
  sensitive = true
}

# For Debugging Purpose

# output "cc_resource_group" {
#   value = module.regional_platform_infrastructure["canadaeast"].cc_resource_group
# }

# output "cc_vnet" {
#   value = module.regional_platform_infrastructure["canadaeast"].cc_vnet
# }

# output "nsgs" {
#   value = module.regional_platform_infrastructure["canadaeast"].nsgs
# }

# output "route_tables" {
#   value = module.regional_platform_infrastructure["canadaeast"].route_tables
# }

# output "user_assigned_identities" {
#   value = module.regional_platform_infrastructure["canadaeast"].user_assigned_identities
# }

# output "keyvaults" {
#   value = module.regional_platform_infrastructure["canadaeast"].keyvaults
# }

# output "disk_encryption_sets" {
#   value = module.regional_platform_infrastructure["canadaeast"].disk_encryption_sets
# }

# output "virtual_machine_configs" {
#   value = module.regional_platform_infrastructure["canadaeast"].virtual_machine_configs
# }

# output "recovery_vault_config" {
#   value = module.regional_platform_infrastructure["canadaeast"].recovery_vault_config
# }

# output "log_analytics_workspace" {
#   value = module.regional_platform_infrastructure["canadaeast"].log_analytics_workspace
# }

# output "storage_account" {
#   value = module.regional_platform_infrastructure["canadaeast"].storage_account
# }

# output "NIC_subnet_key" {
#   value = module.regional_platform_infrastructure["canadaeast"].NIC_subnet_key
# }

# output "private_endpoint_subnet_key" {
#   value = module.regional_platform_infrastructure["canadaeast"].private_endpoint_subnet_key
# }