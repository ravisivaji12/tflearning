module "log_analytics_workspace" {
  source                                    = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version                                   = "0.4.2"
  location                                  = var.cc_location
  resource_group_name                       = var.cc_core_resource_group_name
  name                                      = var.cc_core_law_name
  log_analytics_workspace_retention_in_days = 30
  log_analytics_workspace_sku               = var.cc_core_law_sku
  log_analytics_workspace_identity = {
    type = "SystemAssigned"
  }
}