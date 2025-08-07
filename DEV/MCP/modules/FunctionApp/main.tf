module "metadata-functionapp_nonprod" {
  source          = "app.terraform.io/Mccain_Foods/azure-metadata/platform"
  version         = "0.0.11"
  organization    = var.organization
  lob_or_platform = var.lob_or_platform
  environment     = var.environment_dev
  application     = var.application_name_dev
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
  sub_component   = ""
}


module "metadata-functionapp_Linux_nonprod" {
  source          = "app.terraform.io/Mccain_Foods/azure-metadata/platform"
  version         = "0.0.11"
  organization    = var.organization
  lob_or_platform = var.lob_or_platform
  environment     = var.environment_dev
  application     = var.application_name_dev
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
  sub_component   = "lnx"
}



module "resource_group-functionapp_nonprod" {
  providers = {
    azurerm = azurerm
    azuread = azuread
  }
  source   = "app.terraform.io/Mccain_Foods/azure-resource-group/platform"
  version  = "0.0.1"
  metadata = module.metadata-functionapp_nonprod
}

# Have to ignore the above warning as making the storage account private causes issues with Function deployment
#tfsec:ignore:azure-storage-default-action-deny
module "storage_account_functionapp" {
  source                        = "Azure/avm-res-storage-storageaccount/azurerm"
  version                       = "0.6.4"
  name                          = module.metadata-functionapp_nonprod.resource_names.storage_account
  location                      = module.metadata-functionapp_nonprod.metadata_object.region
  resource_group_name           = module.resource_group-functionapp_nonprod.resource_group_name
  tags                          = module.metadata-functionapp_nonprod.tags
  enable_telemetry              = false
  shared_access_key_enabled     = true
  public_network_access_enabled = true
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  blob_properties = {
    delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
  }
  network_rules = {
    default_action = "Allow"
    bypass         = ["AzureServices"]

    # Defender for Storage Data Scanner
    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.cfg_core_infrastructure_subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.cfg_tenant_id
    }]
  }

}

module "app_service_plan_functionapp" {
  source              = "Azure/avm-res-web-serverfarm/azurerm"
  version             = "0.7.0"
  name                = module.metadata-functionapp_nonprod.resource_names.app_service_plan
  location            = module.metadata-functionapp_nonprod.metadata_object.region
  resource_group_name = module.resource_group-functionapp_nonprod.resource_group_name
  tags                = module.metadata-functionapp_nonprod.tags
  enable_telemetry    = false

  sku_name = "P1v3"
  os_type  = "Windows"
}

module "log_analytics_workspace_functionapp" {
  source              = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version             = "0.4.2"
  name                = module.metadata-functionapp_nonprod.resource_names.log_analytics_workspace
  location            = module.metadata-functionapp_nonprod.metadata_object.region
  resource_group_name = module.resource_group-functionapp_nonprod.resource_group_name
  tags                = module.metadata-functionapp_nonprod.tags
  enable_telemetry    = false

  log_analytics_workspace_retention_in_days          = 30
  log_analytics_workspace_internet_ingestion_enabled = true
  log_analytics_workspace_internet_query_enabled     = true
}

data "azurerm_user_assigned_identity" "finops_parking_uai" {
  name                = "mf-cc-core-finops-parking-npr-id"
  resource_group_name = "mf-cc-core-identities-npr-rg"
}

module "function_app_windows" {
  depends_on                    = [module.storage_account_functionapp, module.log_analytics_workspace_functionapp]
  source                        = "Azure/avm-res-web-site/azurerm"
  version                       = "0.17.2"
  name                          = module.metadata-functionapp_nonprod.resource_names.function_app
  location                      = module.metadata-functionapp_nonprod.metadata_object.region
  resource_group_name           = module.resource_group-functionapp_nonprod.resource_group_name
  tags                          = module.metadata-functionapp_nonprod.tags
  enable_telemetry              = false
  kind                          = "functionapp"
  os_type                       = "Windows"
  https_only                    = true
  service_plan_resource_id      = module.app_service_plan_functionapp.resource.id
  storage_account_name          = module.storage_account_functionapp.name
  storage_account_access_key    = module.storage_account_functionapp.resource.primary_access_key
  storage_uses_managed_identity = false

  application_insights = {
    workspace_resource_id = module.log_analytics_workspace_functionapp.resource_id
  }

  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [data.azurerm_user_assigned_identity.finops_parking_uai.id]
  }

  site_config = {
    always_on = true
    powershell_core_version = {
      version = "7.4"
    }
  }

  app_settings = merge({
    FUNCTIONS_WORKER_RUNTIME            = "powershell"
    "AzureWebJobs.vm-shutdown.Disabled" = "1"
  }, var.additional_app_settings)

}



module "function_app_linux" {
  depends_on                    = [module.storage_account_functionapp, module.log_analytics_workspace_functionapp]
  source                        = "Azure/avm-res-web-site/azurerm"
  version                       = "0.17.2"
  name                          = module.metadata-functionapp_Linux_nonprod.resource_names.function_app
  location                      = module.metadata-functionapp_Linux_nonprod.metadata_object.region
  resource_group_name           = module.resource_group-functionapp_nonprod.resource_group_name
  tags                          = module.metadata-functionapp_Linux_nonprod.tags
  enable_telemetry              = false
  kind                          = "functionapp"
  os_type                       = "Linux"
  https_only                    = true
  service_plan_resource_id      = module.app_service_plan_functionapp_linux.resource.id
  storage_account_name          = module.storage_account_functionapp.name
  storage_account_access_key    = module.storage_account_functionapp.resource.primary_access_key
  storage_uses_managed_identity = false

  application_insights = {
    workspace_resource_id = module.log_analytics_workspace_functionapp.resource_id
  }

  managed_identities = {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.finops-parkingtime-prd.id]
  }

  site_config = {
    always_on        = true
    linux_fx_version = "PYTHON|3.12"
    application_stack = {
      "python" : {
        python_version     = "3.12"
        use_custom_runtime = false
      }
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }

}

data "azurerm_user_assigned_identity" "finops-parkingtime-prd" {
  name                = "mf-cc-core-finops-parkingtime-prd-id"
  resource_group_name = "mf-cc-core-identities-prd-rg"
}




module "app_service_plan_functionapp_linux" {
  source              = "Azure/avm-res-web-serverfarm/azurerm"
  version             = "0.7.0"
  name                = module.metadata-functionapp_Linux_nonprod.resource_names.app_service_plan
  location            = module.metadata-functionapp_Linux_nonprod.metadata_object.region
  resource_group_name = module.resource_group-functionapp_nonprod.resource_group_name
  tags                = module.metadata-functionapp_Linux_nonprod.tags
  enable_telemetry    = false

  sku_name = "P1v3"
  os_type  = "Linux"
}