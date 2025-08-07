
resource "azurerm_container_app_environment" "this" {
  name                           = var.MF_MDI_CC-CAPPENV_NAME
  resource_group_name            = var.cc_core_resource_group_name
  location                       = var.cc_location
  infrastructure_subnet_id       = local.aca_infrastructure_subnet_id
  internal_load_balancer_enabled = true
  #   log_analytics_workspace_id     = azurerm_log_analytics_workspace.MF_MDI_CC_CORE_LAW.id
}

module "container_apps" {
  source                                = "Azure/avm-res-app-containerapp/azurerm"
  version                               = "0.6.0"
  for_each                              = local.container_apps
  name                                  = each.key
  resource_group_name                   = var.cc_core_resource_group_name
  container_app_environment_resource_id = azurerm_container_app_environment.this.id
  revision_mode                         = each.value.revision_mode

  template = each.value.template
  # managed_identities = each.value.managed_identities
  # registries         = each.value.registries
  ingress          = each.value.ingress
  role_assignments = each.value.role_assignments

}

output "name" {
  value     = module.container_apps["mf-mdi-cc-prod-capp-mdiauthsvc"]
  sensitive = true
}