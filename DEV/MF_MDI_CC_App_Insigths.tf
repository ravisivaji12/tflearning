module "avm-res-insights-component" {
  source  = "Azure/avm-res-insights-component/azurerm"
  version = "0.1.5"
  # insert the 4 required variables here
  name                = var.cc_core_appinsights_name
  resource_group_name = module.MF_MDI_CC-RG.name
  location            = var.cc_location
  workspace_id        = module.log_analytics_workspace.resource_id
  application_type    = "web"
  tags                = local.tag_list_1
}