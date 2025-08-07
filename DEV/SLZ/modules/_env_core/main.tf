# Adding Kyndryl group access to VMs for VM configuration.
data "azuread_group" "sysops_ad_group" {
  provider     = azuread.azuread_mccaingroup_onmicrosoft_com
  display_name = var.iaas_sysops_group_name
}

resource "azurerm_role_assignment" "syspos_vm_contirbutor" {
  provider             = azurerm.azurerm_core_infrastructure_provider
  principal_id         = data.azuread_group.sysops_ad_group.object_id
  role_definition_name = "Virtual Machine Contributor"
  scope                = var.sap_root_mg_resource_id
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "sysops_reader" {
  provider             = azurerm.azurerm_core_infrastructure_provider
  principal_id         = data.azuread_group.sysops_ad_group.object_id
  role_definition_name = "Reader"
  scope                = var.sap_root_mg_resource_id
  principal_type       = "Group"
}