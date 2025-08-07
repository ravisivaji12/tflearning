data "azurerm_client_config" "current" {}

module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.0"

  location                        = var.cc_location
  name                            = var.kv_name
  resource_group_name             = var.cc_core_resource_group_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.sku_name
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment

  legacy_access_policies_enabled = true
  legacy_access_policies         = var.kv_legacy_access_policies
  role_assignments               = var.kv_role_assignments

}
