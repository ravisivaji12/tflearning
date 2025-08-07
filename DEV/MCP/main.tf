module "FunctionApp-FinOpsParking" {
  source                  = "./modules/FunctionApp/"
  application_name_dev    = var.application_name_dev
  built_using             = var.built_using
  business_owner          = var.business_owner
  gl_code                 = var.gl_code
  iac_creator             = var.iac_creator
  iac_owner               = var.iac_owner
  it_owner                = var.it_owner
  network_posture         = var.network_posture
  organization            = var.organization
  lob_or_platform         = var.lob_or_platform
  terraform_id            = var.terraform_id
  region                  = var.region
  environment_dev         = var.environment_dev
  modified_date           = var.modified_date
  onboarding_date         = var.onboarding_date
  cfg_aad_client_secret   = var.cfg_aad_client_secret
  additional_app_settings = var.additional_finops_parking_function_app_settings
  providers = {
    azurerm = azurerm
    azuread = azuread
  }
}

module "regional_platform_infrastructure" {
  providers = {
    azurerm = azurerm
    azuread = azuread
    azapi   = azapi
  }
  for_each                          = var.platform_infrastructure_regional_footprint
  source                            = "./modules/regional_platform_infra"
  organization                      = var.organization
  lob_or_platform                   = var.lob_or_platform
  environment                       = var.environment
  region                            = each.key
  gl_code                           = var.gl_code
  it_owner                          = var.it_owner
  business_owner                    = var.business_owner
  iac_creator                       = var.iac_creator
  iac_owner                         = var.iac_owner
  network_posture                   = var.network_posture
  built_using                       = var.built_using
  terraform_id                      = var.terraform_id
  onboarding_date                   = var.onboarding_date
  modified_date                     = var.modified_date
  cfg_tenant_id                     = var.cfg_tenant_id
  domain_controller_vnet_config     = each.value.domain_controller_vnet_config
  domain_controller_private_ip_1    = each.value.domain_controller_private_ip_1
  domain_controller_private_ip_2    = each.value.domain_controller_private_ip_2
  domain_controller_password        = each.value.domain_controller_password
  domain_controller_suffix_1        = each.value.domain_controller_suffix_1
  domain_controller_suffix_2        = each.value.domain_controller_suffix_2
  hub_vnet_id                       = each.value.hub_vnet_id
  hub_vnet_name                     = each.value.hub_vnet_name
  image_gallery_resource_group_name = each.value.image_gallery_resource_group_name
  image_gallery_name                = each.value.image_gallery_name
  enable_dc_vnet_peering            = each.value.enable_dc_vnet_peering
}

# Enable Defender
resource "azurerm_security_center_subscription_pricing" "defender_enablement" {
  for_each = var.defender_plans

  tier          = "Standard"
  resource_type = each.value.resource_type
  subplan       = each.value.sub_plan
  dynamic "extension" {
    for_each = each.value.extensions
    content {
      name                            = extension.value.name
      additional_extension_properties = extension.value.additional_properties
    }
  }
}