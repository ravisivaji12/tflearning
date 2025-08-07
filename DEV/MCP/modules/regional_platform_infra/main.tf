# Domain Controller
module "metadata-domain_controller" {
  source          = "app.terraform.io/Mccain_Foods/azure-metadata/platform"
  version         = "0.0.11"
  app_code        = ""
  organization    = var.organization
  lob_or_platform = var.lob_or_platform
  environment     = var.environment
  application     = var.application_name_domain_controllers
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_creator
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date
  modified_date   = var.modified_date
  region          = var.region
  sub_component   = var.domain_controller_component_name
}

module "metadata-domain_controller_subnets" {
  for_each        = var.domain_controller_vnet_config.subnets
  source          = "app.terraform.io/Mccain_Foods/azure-metadata/platform"
  version         = "0.0.11"
  app_code        = ""
  organization    = var.organization
  lob_or_platform = var.lob_or_platform
  environment     = var.environment
  application     = var.application_name_domain_controllers
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_creator
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date
  modified_date   = var.modified_date
  region          = var.region
  sub_component   = "${var.domain_controller_component_name}-${each.value.subnet_identifier}"
}

module "metadata-domain_controller-vm" {
  for_each = {
    "1" : "01",
    "2" : "02"
  }
  source          = "app.terraform.io/Mccain_Foods/azure-metadata/platform"
  version         = "0.0.11"
  app_code        = ""
  organization    = var.organization
  lob_or_platform = var.lob_or_platform
  environment     = var.environment
  application     = var.application_name_domain_controllers
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_creator
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date
  modified_date   = var.modified_date
  region          = var.region
  sub_component   = var.domain_controller_component_name
  suffix          = each.value
}

module "DomainControllers" {
  providers = {
    azurerm = azurerm
    azapi   = azapi
  }
  source                                       = "../../modules/DomainController"
  enable_telemetry                             = false
  cc_resource_group                            = local.domain_controller_parameters.cc_resource_group
  cc_vnet                                      = local.domain_controller_parameters.cc_vnet
  nsgs                                         = local.domain_controller_parameters.nsgs
  route_tables                                 = local.domain_controller_parameters.route_tables
  user_assigned_identities                     = local.domain_controller_parameters.user_assigned_identities
  keyvaults                                    = local.domain_controller_parameters.keyvaults
  disk_encryption_sets                         = local.domain_controller_parameters.disk_encryption_sets
  virtual_machine_configs                      = local.domain_controller_parameters.virtual_machine_configs
  recovery_vault_config                        = local.domain_controller_parameters.recovery_vault_config
  log_analytics_workspace                      = local.domain_controller_parameters.log_analytics_workspace
  storage_account                              = local.domain_controller_parameters.storage_account
  private_endpoint_subnet_key                  = var.private_endpoint_subnet_key
  NIC_subnet_key                               = var.NIC_subnet_key
  identity_key                                 = var.identity_key
  key_vault_key                                = var.key_vault_key
  disk_encryption_set_config_key               = var.disk_encryption_set_config_key
  storage_account_private_dns_zone_resource_id = var.storage_account_private_dns_zone_resource_id
  key_vault_private_dns_zone_resource_id       = var.key_vault_private_dns_zone_resource_id
  encryption_key_name                          = var.encryption_key_name
  hub_vnet_id                                  = var.hub_vnet_id
  hub_vnet_name                                = var.hub_vnet_name
  vm_login_username                            = var.default_vm_username
  enable_peering                               = var.enable_dc_vnet_peering
  backup_policy_identifier                     = module.metadata-domain_controller.resource_names.recovery_services_vault_policy
}

# Image gallery
module "metadata-image_gallery" {
  source          = "app.terraform.io/Mccain_Foods/azure-metadata/platform"
  version         = "0.0.11"
  app_code        = ""
  organization    = var.organization
  lob_or_platform = var.lob_or_platform
  environment     = var.environment
  application     = var.application_name_domain_controllers
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_creator
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date
  modified_date   = var.modified_date
  region          = var.region
  sub_component   = "Image Gallery"
}

module "resource_group-image_gallery" {
  providers = {
    azurerm = azurerm
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = length(var.image_gallery_resource_group_name) > 0 ? var.image_gallery_resource_group_name : module.metadata-image_gallery.resource_names.resource_group
  location         = module.metadata-image_gallery.metadata_object.region
  tags             = module.metadata-image_gallery.tags
  enable_telemetry = false
}

module "log_analytics_workspace-image_gallery" {
  providers = {
    azurerm = azurerm
  }
  source                                             = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version                                            = "0.4.2"
  name                                               = module.metadata-image_gallery.resource_names.log_analytics_workspace
  resource_group_name                                = module.resource_group-image_gallery.name
  location                                           = module.metadata-image_gallery.metadata_object.region
  tags                                               = module.metadata-image_gallery.tags
  log_analytics_workspace_internet_ingestion_enabled = true
  log_analytics_workspace_internet_query_enabled     = true
  log_analytics_workspace_retention_in_days          = 30
  enable_telemetry                                   = false
}

# Adding manual resource as cannot refer to itself in AVM module
resource "azurerm_monitor_diagnostic_setting" "log_analytics_workspace-image_gallery" {
  provider                       = azurerm
  name                           = "default"
  target_resource_id             = module.log_analytics_workspace-image_gallery.resource_id
  log_analytics_destination_type = "Dedicated"
  log_analytics_workspace_id     = module.log_analytics_workspace-image_gallery.resource_id

  dynamic "enabled_log" {
    for_each = toset(["Audit", "SummaryLogs"])
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(["AllMetrics"])
    content {
      category = metric.value
    }
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

module "image_gallery" {
  providers = {
    azurerm                                     = azurerm
    azuread.azuread_mccaingroup_onmicrosoft_com = azuread
  }
  source                                                       = "../../modules/image_gallery"
  resource_group_name                                          = module.resource_group-image_gallery.name
  location                                                     = module.metadata-image_gallery.metadata_object.region
  tags                                                         = module.metadata-image_gallery.tags
  name                                                         = length(var.image_gallery_name) > 0 ? var.image_gallery_name : module.metadata-image_gallery.resource_names.image_gallery
  reader_access_AD_group_names                                 = var.reader_access_AD_group_names
  contributor_access_AD_group_names                            = var.contributor_access_AD_group_names
  contributor_access_service_principal_object_ids              = var.contributor_access_service_principal_object_ids
  contributor_access_user_assigned_managed_identity_object_ids = var.contributor_access_user_assigned_managed_identity_object_ids
}