module "avm-res-storage-storageaccount" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.1"

  for_each                  = local.storage_accounts
  account_replication_type  = "LRS"
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  location                  = var.cc_location
  resource_group_name       = var.cc_core_resource_group_name
  name                      = each.value.name
  shared_access_key_enabled = true
  tags                      = local.tag_list_1
  containers                = each.value.containers
  # role_assignments         = each.value.role_assignments
  managed_identities = {
    system_assigned = true
  }
}

output "containers" {
  value     = module.container_apps["mf-mdi-cc-prod-capp-ddh-github"].resource
  sensitive = true
}
