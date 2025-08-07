

# locals {
#   merged_function_apps = var.cc_core_function_apps
# }

# # Storage accounts (for access keys)
# data "azurerm_storage_account" "storageaccount" {
#   for_each = var.cc_core_function_apps

#   name                = each.value.storage_account_name
#   resource_group_name = each.value.storage_account_rg
#   depends_on          = [module.MF_MDI_CC-RG]
# }

# # App Insights
# data "azurerm_application_insights" "appinsights" {
#   for_each = var.cc_core_function_apps

#   name                = each.value.app_insights_name
#   resource_group_name = each.value.app_insights_rg
#   depends_on          = [module.MF_MDI_CC-RG, module.avm-res-storage-storageaccount]
# }

# # User Assigned Identity
# data "azurerm_user_assigned_identity" "useraid" {
#   for_each = var.cc_core_function_apps

#   name                = each.value.user_assigned_identity_name
#   resource_group_name = each.value.user_assigned_identity_rg
#   depends_on          = [module.MF_MDI_CC-RG, module.avm-res-storage-storageaccount, azurerm_user_assigned_identity.MF_MDI_CC_CORE_APP_ACCESS-USER-IDENTITY]
# }


# resource "azurerm_app_service_plan" "MFDMCCASPAFUNC" {

#   name                = var.cc_core_app_service_plans.name
#   location            = var.cc_core_app_service_plans.location
#   resource_group_name = var.cc_core_app_service_plans.resource_group_name
#   kind                = var.cc_core_app_service_plans.kind

#   sku {
#     tier = var.cc_core_app_service_plans.sku.tier
#     size = var.cc_core_app_service_plans.sku.size
#   }

#   depends_on = [module.MF_MDI_CC-RG]
# }

# module "avm_res_web_site" {
#   source  = "Azure/avm-res-web-site/azurerm"
#   version = "0.16.4"

#   for_each = local.merged_function_apps

#   enable_telemetry = true

#   name                = each.value.name
#   resource_group_name = module.MF_MDI_CC-RG.name
#   location            = each.value.location

#   kind = "functionapp"

#   # Uses an existing app service plan
#   os_type                  = each.value.os_type
#   service_plan_resource_id = azurerm_app_service_plan.MFDMCCASPAFUNC.id

#   # Uses an existing storage account for the function app, fetch the access key using Data resource
#   storage_account_name       = each.value.storage_account_name
#   storage_account_access_key = data.azurerm_storage_account.storageaccount[each.key].primary_access_key
#   # storage_uses_managed_identity = true
#   virtual_network_subnet_id = module.avm-res-network-virtualnetwork[each.value.network_name].subnets[each.value.subnet_name].resource_id

#   managed_identities = {
#     type         = "SystemAssigned, UserAssigned"
#     identity_ids = [data.azurerm_user_assigned_identity.useraid[each.key].id]
#   }

#   site_config = {
#     always_on = true
#   }

#   application_insights = {
#     workspace_resource_id = module.log_analytics_workspace.resource_id
#   }

#   app_settings = merge(
#     {
#       APPINSIGHTS_INSTRUMENTATIONKEY        = data.azurerm_application_insights.appinsights[each.key].instrumentation_key
#       APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.appinsights[each.key].connection_string
#       mdiaiUserAssignedMIClientID           = data.azurerm_user_assigned_identity.useraid[each.key].client_id
#     },
#     each.value.additional_app_settings
#   )

#   tags = local.tag_list_1

#   depends_on = [module.MF_MDI_CC-RG, module.avm-res-storage-storageaccount, azurerm_user_assigned_identity.MF_MDI_CC_CORE_APP_ACCESS-USER-IDENTITY, module.avm-res-network-virtualnetwork["vnet1"], azurerm_app_service_plan.MFDMCCASPAFUNC]

# }