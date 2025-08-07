module "metadata" {
  source          = "../../modules/metadata"
  organization    = var.organization
  solution        = var.solution
  environment     = var.environment
  application     = var.application
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_owner
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date_tools
  modified_date   = var.modified_date_tools
  region          = var.region
}

module "metadata-dev" {
  source          = "../../modules/metadata"
  organization    = var.organization
  solution        = var.solution
  environment     = var.environment-dev
  application     = var.application
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_owner
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date_tools
  modified_date   = var.modified_date_tools
  region          = var.region
}

module "metadata-prod" {
  source          = "../../modules/metadata"
  organization    = var.organization
  solution        = var.solution
  environment     = var.environment-prod
  application     = var.application
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_owner
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date_tools
  modified_date   = var.modified_date_tools
  region          = var.region
}

module "metadata-dr" {
  source          = "../../modules/metadata"
  organization    = var.organization
  solution        = var.solution
  environment     = var.environment-dr
  application     = var.application
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_owner
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date_tools
  modified_date   = var.modified_date_tools
  region          = var.secondary_region
}

# Helper
module "util" {
  source = "../../modules/util"
}

module "naming-default" {
  source   = "../../modules/naming"
  metadata = module.metadata.metadata_object
}

module "naming-default-ce" {
  source   = "../../modules/naming"
  metadata = module.metadata-dr.metadata_object
}

resource "azurerm_security_center_subscription_pricing" "DefenderForStorage" {
  provider      = azurerm.azurerm_application_provider
  tier          = "Standard"
  resource_type = "StorageAccounts"
  subplan       = "DefenderForStorageV2"

  extension {
    name = "OnUploadMalwareScanning"
    additional_extension_properties = {
      BlobScanResultsOptions         = "BlobIndexTags"
      CapGBPerMonthPerStorageAccount = "-1"
    }
  }

  extension {
    name = "SensitiveDataDiscovery"
  }
}

resource "azurerm_security_center_subscription_pricing" "DefenderForServer" {
  provider      = azurerm.azurerm_application_provider
  tier          = "Standard"
  resource_type = "VirtualMachines"
  subplan       = "P2"

  # extension {
  #   name = "Antimalware"
  #   additional_extension_properties = {
  #     CapGBPerMonthPerServer = "-1"
  #   }
  # }

  # extension {
  #   name = "FileIntegrityMonitoring"
  #   additional_extension_properties = {
  #     DefinedWorkspaceId = module.log_analytics_workspace.resource_id
  #   }
  # }
}


# Foundational
module "naming-foundational" {
  source                   = "../../modules/naming"
  metadata                 = module.metadata.metadata_object
  is_foundational_resource = true
}

module "rg-foundation" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-foundational.resource_group_name
  location         = module.metadata.metadata_object.region
  tags             = module.metadata.tags
  enable_telemetry = false
}

module "provider_registration" {
  providers = {
    azurerm.azurerm_application_provider = azurerm.azurerm_application_provider
  }
  source = "../../modules/provider_registration"
  providers_to_be_registered = [
    "Microsoft.Storage", "Microsoft.Network", "Microsoft.Compute", "Microsoft.OperationalInsights", "Microsoft.KeyVault",
    "Microsoft.RecoveryServices"
  ]
}

module "log_analytics_workspace" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                                             = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version                                            = "0.4.2"
  name                                               = module.naming-foundational.log_analytics_workspace_name
  resource_group_name                                = module.rg-foundation.name
  location                                           = module.metadata.metadata_object.region
  tags                                               = module.metadata.tags
  log_analytics_workspace_internet_ingestion_enabled = true
  log_analytics_workspace_internet_query_enabled     = true
  log_analytics_workspace_retention_in_days          = 30
  enable_telemetry                                   = false

  depends_on = [module.provider_registration]
}

module "log_analytics_workspace-ce" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                                             = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version                                            = "0.4.2"
  name                                               = module.naming-foundational-ce.log_analytics_workspace_name
  resource_group_name                                = module.rg-foundation-ce.name
  location                                           = module.metadata-dr.metadata_object.region
  tags                                               = module.metadata-dr.tags
  log_analytics_workspace_internet_ingestion_enabled = true
  log_analytics_workspace_internet_query_enabled     = true
  log_analytics_workspace_retention_in_days          = 30
  enable_telemetry                                   = false

  depends_on = [module.provider_registration]
}

# Adding manual resource as cannot refer to itself in AVM module
resource "azurerm_monitor_diagnostic_setting" "log_analytics_workspace" {
  provider                       = azurerm.azurerm_application_provider
  name                           = "default"
  target_resource_id             = module.log_analytics_workspace.resource_id
  log_analytics_destination_type = "Dedicated"
  log_analytics_workspace_id     = module.log_analytics_workspace.resource_id

  dynamic "enabled_log" {
    for_each = toset(module.util.diagnostic_settings_helper.log_analytics_workspace.log_categories)
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(module.util.diagnostic_settings_helper.log_analytics_workspace.metric_categories)
    content {
      category = metric.value
    }
  }

  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

module "storage_account-foundational" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                    = "Azure/avm-res-storage-storageaccount/azurerm"
  version                   = "0.5.0"
  name                      = module.naming-foundational.storage_account_name
  resource_group_name       = module.rg-foundation.name
  location                  = module.metadata.metadata_object.region
  shared_access_key_enabled = false
  tags                      = module.metadata.tags
  diagnostic_settings_storage_account = {
    default-account : {
      name                  = "default-account"
      log_categories        = module.util.diagnostic_settings_helper.storage_account.log_categories
      metric_categories     = module.util.diagnostic_settings_helper.storage_account.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  diagnostic_settings_blob = {
    default-blob : {
      name                  = "default-blob"
      log_category_groups   = ["allLogs"]
      metric_categories     = module.util.diagnostic_settings_helper.storage_account_blob.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  network_rules = {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]

    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.MF_tenant_id
    }]
  }

  blob_properties = {
    delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
  }

  managed_identities = {
    user_assigned_resource_ids = toset([module.user_assigned_managed_identity-foundational.resource_id])
  }

  customer_managed_key = {
    key_name              = module.naming-foundational.storage_account_name
    key_vault_resource_id = module.key_vault.resource_id
    user_assigned_identity = {
      resource_id = module.user_assigned_managed_identity-foundational.resource_id
    }
  }

  private_endpoints = {
    blob = {
      name                            = module.naming-foundational.private_endpoint_names.storage_account.blob
      subnet_resource_id              = module.virtual_network.subnets["PrivateEndpoints"].resource_id
      private_dns_zone_ids            = [var.storage_blob_private_dns_zone_resource_id]
      subresource_name                = "blob"
      private_dns_zone_resource_ids   = [var.storage_blob_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-default.virtual_network_name}"
      network_interface_name          = "${module.naming-foundational.private_endpoint_names.storage_account.blob}-nic"
      tags                            = module.metadata.tags
      ip_configurations = {
        blob_default = {
          name               = "${module.naming-foundational.private_endpoint_names.storage_account.blob}-nic-ipconfig"
          private_ip_address = var.foundational_storage_account_private_endpoint_ip
        }
      }
    }
  }

  enable_telemetry = false

  account_replication_type = "GRS"

  depends_on = [module.provider_registration]
}

resource "azurerm_management_lock" "storage_account_foundational_lock" {
  provider   = azurerm.azurerm_application_provider
  name       = "${module.naming-foundational.storage_account_name}-lock"
  scope      = module.storage_account-foundational.resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is to prevent accidental deletion of the foundational storage account."
  depends_on = [module.storage_account-foundational]
}

module "storage_account-foundational-ce" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                    = "Azure/avm-res-storage-storageaccount/azurerm"
  version                   = "0.5.0"
  name                      = module.naming-foundational-ce.storage_account_name
  resource_group_name       = module.rg-foundation-ce.name
  location                  = module.metadata-dr.metadata_object.region
  shared_access_key_enabled = false
  tags                      = module.metadata-dr.tags
  account_replication_type  = "LRS"
  diagnostic_settings_storage_account = {
    default-account : {
      name                  = "default-account"
      log_categories        = module.util.diagnostic_settings_helper.storage_account.log_categories
      metric_categories     = module.util.diagnostic_settings_helper.storage_account.metric_categories
      workspace_resource_id = module.log_analytics_workspace-ce.resource_id
    }
  }
  diagnostic_settings_blob = {
    default-blob : {
      name                  = "default-blob"
      log_category_groups   = ["allLogs"]
      metric_categories     = module.util.diagnostic_settings_helper.storage_account_blob.metric_categories
      workspace_resource_id = module.log_analytics_workspace-ce.resource_id
    }
  }
  network_rules = {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]

    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.MF_tenant_id
    }]
  }
  enable_telemetry = false

  private_endpoints = {
    blob = {
      name                            = module.naming-foundational-ce.private_endpoint_names.storage_account.blob
      subnet_resource_id              = module.virtual_network-tools-ce.subnets["PrivateEndpoints2"].resource_id
      private_dns_zone_ids            = [var.storage_blob_private_dns_zone_resource_id]
      subresource_name                = "blob"
      private_dns_zone_resource_ids   = [var.storage_blob_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-tools_vnet-ce.virtual_network_name}"
      network_interface_name          = "${module.naming-foundational-ce.private_endpoint_names.storage_account.blob}-nic"
      tags                            = module.metadata.tags
      ip_configurations = {
        blob_default = {
          name               = "${module.naming-foundational-ce.private_endpoint_names.storage_account.blob}-nic-ipconfig"
          private_ip_address = var.secondary_foundational_storage_account_private_endpoint_ip
        }
      }
    }
  }
  blob_properties = {
    delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
  }

  managed_identities = {
    user_assigned_resource_ids = toset([module.user_assigned_managed_identity-foundational-ce.resource_id])
  }

  customer_managed_key = {
    key_name              = module.naming-foundational-ce.storage_account_name
    key_vault_resource_id = module.key_vault-ce.resource_id
    user_assigned_identity = {
      resource_id = module.user_assigned_managed_identity-foundational-ce.resource_id
    }
  }

  depends_on = [module.provider_registration]
}

resource "azurerm_management_lock" "storage_account_foundational_ce_lock" {
  provider   = azurerm.azurerm_application_provider
  name       = "${module.naming-foundational-ce.storage_account_name}-lock"
  scope      = module.storage_account-foundational-ce.resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is to prevent accidental deletion of the foundational storage account in the secondary region."
  depends_on = [module.storage_account-foundational-ce]
}

module "user_assigned_managed_identity-foundational" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.3.3"
  name                = module.naming-foundational.user_assigned_managed_identity_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata.metadata_object.region
  tags                = module.metadata.tags
  enable_telemetry    = false
}

module "user_assigned_managed_identity-foundational-ce" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.3.3"
  name                = module.naming-foundational-ce.user_assigned_managed_identity_name
  resource_group_name = module.rg-foundation-ce.name
  location            = module.metadata-secondary.metadata_object.region
  tags                = module.metadata-secondary.tags
  enable_telemetry    = false
}

module "naming-backup" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = "bkp"
}

module "storage_account-backup" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                    = "Azure/avm-res-storage-storageaccount/azurerm"
  version                   = "0.5.0"
  name                      = module.naming-backup.storage_account_name
  resource_group_name       = module.rg-foundation.name
  location                  = module.metadata.metadata_object.region
  shared_access_key_enabled = false
  tags                      = module.metadata.tags
  diagnostic_settings_storage_account = {
    default-account : {
      name                  = "default-account"
      log_categories        = module.util.diagnostic_settings_helper.storage_account.log_categories
      metric_categories     = module.util.diagnostic_settings_helper.storage_account.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  diagnostic_settings_blob = {
    default-blob : {
      name                  = "default-blob"
      log_category_groups   = ["allLogs"]
      metric_categories     = module.util.diagnostic_settings_helper.storage_account_blob.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  network_rules = {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]

    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.MF_tenant_id
    }]
  }
  enable_telemetry = false

  private_endpoints = {
    blob = {
      name                            = module.naming-backup.private_endpoint_names.storage_account.blob
      subnet_resource_id              = module.virtual_network.subnets["PrivateEndpoints"].resource_id
      private_dns_zone_ids            = [var.storage_blob_private_dns_zone_resource_id]
      subresource_name                = "blob"
      private_dns_zone_resource_ids   = [var.storage_blob_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-default.virtual_network_name}"
      network_interface_name          = "${module.naming-backup.private_endpoint_names.storage_account.blob}-nic"
      tags                            = module.metadata.tags
      ip_configurations = {
        blob_default = {
          name               = "${module.naming-backup.private_endpoint_names.storage_account.blob}-nic-ipconfig"
          private_ip_address = var.backup_storage_account_private_endpoint_ip
        }
      }
    }
  }

  blob_properties = {
    delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
  }

  managed_identities = {
    user_assigned_resource_ids = toset([module.user_assigned_managed_identity-foundational.resource_id])
  }

  customer_managed_key = {
    key_name              = module.naming-backup.storage_account_name
    key_vault_resource_id = module.key_vault.resource_id
    user_assigned_identity = {
      resource_id = module.user_assigned_managed_identity-foundational.resource_id
    }
  }

  account_replication_type = "GRS"

  depends_on = [module.provider_registration]
}

resource "azurerm_management_lock" "storage_account_backup_lock" {
  provider   = azurerm.azurerm_application_provider
  name       = "${module.naming-backup.storage_account_name}-lock"
  scope      = module.storage_account-backup.resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is to prevent accidental deletion of the backup storage account."
  depends_on = [module.storage_account-backup]
}

module "user_assigned_managed_identity-backup" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.3.3"
  name                = module.naming-backup.user_assigned_managed_identity_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata.metadata_object.region
  tags                = module.metadata.tags
  enable_telemetry    = false
}

resource "azurerm_role_assignment" "mi-backup-assignment" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = module.user_assigned_managed_identity-backup.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage_account-backup.resource_id
  principal_type       = "ServicePrincipal"
}

module "naming-backup_secondary" {
  source        = "../../modules/naming"
  metadata      = module.metadata-secondary.metadata_object
  sub_component = "bkp"
}

module "storage_account-backup_secondary" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                    = "Azure/avm-res-storage-storageaccount/azurerm"
  version                   = "0.5.0"
  name                      = module.naming-backup_secondary.storage_account_name
  resource_group_name       = module.rg-foundation-ce.name
  location                  = module.metadata-secondary.metadata_object.region
  shared_access_key_enabled = false
  account_replication_type  = "LRS"
  tags                      = module.metadata-secondary.tags
  diagnostic_settings_storage_account = {
    default-account : {
      name                  = "default-account"
      log_categories        = module.util.diagnostic_settings_helper.storage_account.log_categories
      metric_categories     = module.util.diagnostic_settings_helper.storage_account.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  diagnostic_settings_blob = {
    default-blob : {
      name                  = "default-blob"
      log_category_groups   = ["allLogs"]
      metric_categories     = module.util.diagnostic_settings_helper.storage_account_blob.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  network_rules = {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]

    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.MF_tenant_id
    }]
  }
  enable_telemetry = false

  private_endpoints = {
    blob = {
      name                            = module.naming-backup_secondary.private_endpoint_names.storage_account.blob
      subnet_resource_id              = module.virtual_network-tools-ce.subnets["PrivateEndpoints2"].resource_id
      private_dns_zone_ids            = [var.storage_blob_private_dns_zone_resource_id]
      subresource_name                = "blob"
      private_dns_zone_resource_ids   = [var.storage_blob_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-tools_vnet-ce.virtual_network_name}"
      network_interface_name          = "${module.naming-backup_secondary.private_endpoint_names.storage_account.blob}-nic"
      tags                            = module.metadata-secondary.tags
      ip_configurations = {
        blob_default = {
          name               = "${module.naming-backup_secondary.private_endpoint_names.storage_account.blob}-nic-ipconfig"
          private_ip_address = var.secondary_backup_storage_account_private_endpoint_ip
        }
      }
    }
  }

  blob_properties = {
    delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
  }

  managed_identities = {
    user_assigned_resource_ids = toset([module.user_assigned_managed_identity-foundational-ce.resource_id])
  }

  customer_managed_key = {
    key_name              = module.naming-backup_secondary.storage_account_name
    key_vault_resource_id = module.key_vault-ce.resource_id
    user_assigned_identity = {
      resource_id = module.user_assigned_managed_identity-foundational-ce.resource_id
    }
  }

  depends_on = [module.provider_registration]
}

resource "azurerm_management_lock" "storage_account_backup_secondary_lock" {
  provider   = azurerm.azurerm_application_provider
  name       = "${module.naming-backup_secondary.storage_account_name}-lock"
  scope      = module.storage_account-backup_secondary.resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is to prevent accidental deletion of the backup storage account in the secondary region."
  depends_on = [module.storage_account-backup_secondary]
}

module "user_assigned_managed_identity-backup_secondary" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.3.3"
  name                = module.naming-backup_secondary.user_assigned_managed_identity_name
  resource_group_name = module.rg-foundation-ce.name
  location            = module.metadata-secondary.metadata_object.region
  tags                = module.metadata-secondary.tags
  enable_telemetry    = false
}

resource "azurerm_role_assignment" "mi-backup-assignment-secondary" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = module.user_assigned_managed_identity-backup_secondary.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage_account-backup_secondary.resource_id
  principal_type       = "ServicePrincipal"
}

data "azurerm_client_config" "SPN" {
  provider = azurerm.azurerm_application_provider
}

resource "azurerm_role_assignment" "iac-spn-key-vault-officer-assignment" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = data.azurerm_client_config.SPN.object_id
  role_definition_name = "Key Vault Administrator"
  scope                = module.rg-foundation.resource_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "iac-spn-key-vault-officer-assignment-ce" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = data.azurerm_client_config.SPN.object_id
  role_definition_name = "Key Vault Administrator"
  scope                = module.rg-foundation-ce.resource_id
  principal_type       = "ServicePrincipal"
}

module "key_vault" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-keyvault-vault/azurerm"
  version             = "0.10.0"
  name                = module.naming-default.key_vault_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata.metadata_object.region
  tenant_id           = var.MF_tenant_id

  diagnostic_settings = {
    "default" : {
      name                  = "default"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  enabled_for_disk_encryption   = true
  enabled_for_deployment        = true
  public_network_access_enabled = false
  soft_delete_retention_days    = 90

  network_acls = {
    bypass = "AzureServices"
  }

  private_endpoints = {
    vault = {
      name                            = module.naming-default.private_endpoint_names.key_vault.vault
      subnet_resource_id              = module.virtual_network-tools.subnets["PrivateEndpoints2"].resource_id
      private_dns_zone_ids            = [var.key_vault_private_dns_zone_resource_id]
      subresource_name                = "vault"
      private_dns_zone_resource_ids   = [var.key_vault_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-tools_vnet.virtual_network_name}"
      network_interface_name          = "${module.naming-default.private_endpoint_names.key_vault.vault}-nic"
      tags                            = module.metadata.tags
      ip_configurations = {
        vault_default = {
          name               = "${module.naming-default.private_endpoint_names.key_vault.vault}-nic-ipconfig"
          private_ip_address = var.key_vault_private_endpoint_ip
        }
      }
    }
  }

  # Commenting Keys IAC as network restrictions won't allow create as GitHub is running on public runners
  # keys = {
  #   foundational_storage = {
  #     name            = module.naming-foundational.storage_account_name
  #     key_type        = "RSA"
  #     key_opts        = ["decrypt", "encrypt", "sign", "verify", "wrapKey", "unwrapKey"]
  #     key_size        = 2048
  #     not_before_date = "2025-06-10T00:00:00Z"
  #     expiry_date     = "2030-06-30T00:00:00Z"
  #     rotation_policy = {
  #       automatic = {
  #         time_before_expiry  = "P1D"
  #         time_after_creation = "P7D"
  #       }
  #       expire_after         = "P28D"
  #       notify_before_expiry = "P7D"
  #     }
  #   }
  #   backup_storage = {
  #     name            = module.naming-backup.storage_account_name
  #     key_type        = "RSA"
  #     key_opts        = ["decrypt", "encrypt", "sign", "verify", "wrapKey", "unwrapKey"]
  #     key_size        = 2048
  #     not_before_date = "2025-06-10T00:00:00Z"
  #     expiry_date     = "2030-06-30T00:00:00Z"
  #     rotation_policy = {
  #       automatic = {
  #         time_before_expiry  = "P1D"
  #         time_after_creation = "P7D"
  #       }
  #       expire_after         = "P28D"
  #       notify_before_expiry = "P7D"
  #     }
  #   }
  #   binaries_storage = {
  #     name            = module.naming-binaries.storage_account_name
  #     key_type        = "RSA"
  #     key_opts        = ["decrypt", "encrypt", "sign", "verify", "wrapKey", "unwrapKey"]
  #     key_size        = 2048
  #     not_before_date = "2025-06-10T00:00:00Z"
  #     expiry_date     = "2030-06-30T00:00:00Z"
  #     rotation_policy = {
  #       automatic = {
  #         time_before_expiry  = "P1D"
  #         time_after_creation = "P7D"
  #       }
  #       expire_after         = "P28D"
  #       notify_before_expiry = "P7D"
  #     }
  #   }
  # }

  tags             = module.metadata.tags
  enable_telemetry = false
}

module "key_vault-ce" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-keyvault-vault/azurerm"
  version             = "0.10.0"
  name                = module.naming-default-ce.key_vault_name
  resource_group_name = module.rg-foundation-ce.name
  location            = module.metadata-dr.metadata_object.region
  tenant_id           = var.MF_tenant_id

  diagnostic_settings = {
    "default" : {
      name                  = "default"
      workspace_resource_id = module.log_analytics_workspace-ce.resource_id
    }
  }

  enabled_for_disk_encryption   = true
  enabled_for_deployment        = true
  public_network_access_enabled = false
  soft_delete_retention_days    = 90

  network_acls = {
    bypass = "AzureServices"
  }

  private_endpoints = {
    vault = {
      name                            = module.naming-default-ce.private_endpoint_names.key_vault.vault
      subnet_resource_id              = module.virtual_network-tools-ce.subnets["PrivateEndpoints2"].resource_id
      private_dns_zone_ids            = [var.key_vault_private_dns_zone_resource_id]
      subresource_name                = "vault"
      private_dns_zone_resource_ids   = [var.key_vault_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-tools_vnet-ce.virtual_network_name}"
      network_interface_name          = "${module.naming-default-ce.private_endpoint_names.key_vault.vault}-nic"
      tags                            = module.metadata-dr.tags
      ip_configurations = {
        vault_default = {
          name               = "${module.naming-default-ce.private_endpoint_names.key_vault.vault}-nic-ipconfig"
          private_ip_address = var.secondary_key_vault_private_endpoint_ip
        }
      }
    }
  }

  # Commenting Keys IAC as network restrictions won't allow create as GitHub is running on public runners
  # keys = {
  #   foundational_storage_ce = {
  #     name            = module.naming-foundational-ce.storage_account_name
  #     key_type        = "RSA"
  #     key_opts        = ["decrypt", "encrypt", "sign", "verify", "wrapKey", "unwrapKey"]
  #     key_size        = 2048
  #     not_before_date = "2025-06-10T00:00:00Z"
  #     expiry_date     = "2030-06-30T00:00:00Z"
  #     rotation_policy = {
  #       automatic = {
  #         time_before_expiry  = "P1D"
  #         time_after_creation = "P7D"
  #       }
  #       expire_after         = "P28D"
  #       notify_before_expiry = "P7D"
  #     }
  #   }
  #   backup_storage_secondary = {
  #     name            = module.naming-backup_secondary.storage_account_name
  #     key_type        = "RSA"
  #     key_opts        = ["decrypt", "encrypt", "sign", "verify", "wrapKey", "unwrapKey"]
  #     key_size        = 2048
  #     not_before_date = "2025-06-10T00:00:00Z"
  #     expiry_date     = "2030-06-30T00:00:00Z"
  #     rotation_policy = {
  #       automatic = {
  #         time_before_expiry  = "P1D"
  #         time_after_creation = "P7D"
  #       }
  #       expire_after         = "P28D"
  #       notify_before_expiry = "P7D"
  #     }
  #   }
  # }

  tags             = module.metadata-dr.tags
  enable_telemetry = false
}

module "naming-tools_vnet" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = "Monitoring Tools"
}

module "virtual_network" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.8.1"
  name                = module.naming-default.virtual_network_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata.metadata_object.region
  address_space       = toset(var.vnet_address_spaces)

  diagnostic_settings = {
    "default" : {
      name                  = "default"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  peerings = {
    "hub" : {
      name                               = "${module.naming-default.virtual_network_name}-${var.hub_vnet_name}"
      remote_virtual_network_resource_id = var.hub_vnet_id
      allow_virtual_network_access       = true
      allow_forwarded_traffic            = true
      create_reverse_peering             = true
      reverse_name                       = "${var.hub_vnet_name}-${module.naming-default.virtual_network_name}"
      allow_gateway_transit              = false
      use_remote_gateways                = false
    }
  }

  subnets = { for k, subnet_info in var.vnet_subnets : "${k}" => {
    name           = subnet_info.name
    address_prefix = subnet_info.address_prefix
    network_security_group = {
      id = module.network_security_groups[subnet_info.network_security_group].resource_id
    }
    route_table = {
      id = module.route_tables[subnet_info.route_table].resource_id
    }
    service_endpoints = ["Microsoft.Storage"]
    }
  }

  dns_servers = {
    dns_servers = toset(var.dns_servers)
  }

  tags             = module.metadata.tags
  enable_telemetry = false
}

module "virtual_network-tools" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.8.1"
  name                = module.naming-tools_vnet.virtual_network_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata.metadata_object.region
  address_space       = toset(var.tools_vnet_address_spaces)

  diagnostic_settings = {
    "default" : {
      name                  = "default"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  # peerings = {
  #   "hub": {
  #     name = "${module.naming-tools_vnet.virtual_network_name}-${var.hub_vnet_name}"
  #     remote_virtual_network_resource_id = var.hub_vnet_id
  #     allow_virtual_network_access = true
  #     allow_forwarded_traffic = true
  #     create_reverse_peering = true
  #     reverse_name = "${var.hub_vnet_name}-${module.naming-tools_vnet.virtual_network_name}"
  #     allow_gateway_transit = false
  #     use_remote_gateways = false
  #   }
  # }

  subnets = { for k, subnet_info in var.tools_vnet_subnets : "${k}" => {
    name           = subnet_info.name
    address_prefix = subnet_info.address_prefix
    network_security_group = {
      id = module.network_security_groups[subnet_info.network_security_group].resource_id
    }
    route_table = {
      id = module.route_tables[subnet_info.route_table].resource_id
    }
    service_endpoints = ["Microsoft.Storage"]
    }
  }

  dns_servers = {
    dns_servers = toset(var.dns_servers)
  }

  tags             = module.metadata.tags
  enable_telemetry = false
}

# module "network_watcher" {
#   source  = "Azure/avm-res-network-networkwatcher/azurerm"
#   version = "0.3.1"
#   network_watcher_name = "${module.naming-tools_vnet.virtual_network_name}-nw"
#   network_watcher_id   = "${module.naming-tools_vnet.virtual_network_name}-nw"
#   resource_group_name  = module.rg-foundation.name
#   location             = module.metadata.metadata_object.region

#   flow_logs = {
#     default = {
#       name                = "${module.naming-tools_vnet.virtual_network_name}-flow-logs"
#       target_resource_id  = module.virtual_network-tools.resource_id
#       enabled             = true
#       storage_account_id  = module.storage_account-foundational.resource_id
#       retention_policy = {
#         days = 30
#         enabled = true
#       }
#       traffic_analytics = {
#         enabled             = true
#         interval_in_minutes = 10
#         workspace_id        = module.log_analytics_workspace.id
#         workspace_region    = module.metadata.metadata_object.region
#         workspace_resource_id = module.log_analytics_workspace.resource_id
#       }
#     }
#   }

#   tags             = module.metadata.tags
#   enable_telemetry = false

#   depends_on = [module.provider_registration]
# }

module "naming-nsgs" {
  source        = "../../modules/naming"
  for_each      = var.network_security_groups
  metadata      = module.metadata.metadata_object
  sub_component = each.value.sub_component_name
}

module "network_security_groups" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.4.0"
  for_each            = var.network_security_groups
  name                = module.naming-nsgs[each.key].network_security_group_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata.metadata_object.region

  diagnostic_settings = {
    "default" : {
      name                  = "default"
      workspace_resource_id = module.log_analytics_workspace.resource_id
      # Adding below as dedicated is not supported as per Azure documentation as of 2025-04-18. Link: https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics#resources-using-azure-diagnostics-mode
      log_analytics_destination_type = "AzureDiagnostics"
    }
  }

  security_rules = [each.value.rules, merge(var.common_nsg_rules, each.value.rules)][each.key == "appgateway" ? 0 : 1]

  tags             = module.metadata.tags
  enable_telemetry = false
}

module "naming-nsgs_secondary" {
  source        = "../../modules/naming"
  for_each      = var.network_security_groups_secondary
  metadata      = module.metadata-secondary.metadata_object
  sub_component = each.value.sub_component_name
}

module "network_security_groups_secondary" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.4.0"
  for_each            = var.network_security_groups_secondary
  name                = module.naming-nsgs_secondary[each.key].network_security_group_name
  resource_group_name = module.rg-foundation-ce.name
  location            = module.metadata-secondary.metadata_object.region

  diagnostic_settings = {
    "default" : {
      name                  = "default"
      workspace_resource_id = module.log_analytics_workspace.resource_id
      # Adding below as dedicated is not supported as per Azure documentation as of 2025-04-18. Link: https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics#resources-using-azure-diagnostics-mode
      log_analytics_destination_type = "AzureDiagnostics"
    }
  }

  security_rules = [each.value.rules, merge(var.common_nsg_rules_secondary, each.value.rules)][each.key == "appgateway" ? 0 : 1]

  tags             = module.metadata.tags
  enable_telemetry = false
}

module "naming-application" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = "App"
}

module "naming-database" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = "Db"
}

module "naming-routetables" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  for_each      = var.route_tables
  sub_component = each.value.name
}

module "route_tables" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.4.1"

  for_each = var.route_tables

  name                = module.naming-routetables[each.key].route_table_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata.metadata_object.region

  routes = each.value.routes

  tags             = module.metadata.tags
  enable_telemetry = false
}

module "naming-routetables_secondary" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  for_each      = var.route_tables
  sub_component = each.value.name
}

module "route_tables_secondary" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.4.1"

  for_each = var.route_tables

  name                = module.naming-routetables_secondary[each.key].route_table_name
  resource_group_name = module.rg-foundation-ce.name
  location            = module.metadata-secondary.metadata_object.region

  routes = each.value.routes

  tags             = module.metadata-secondary.tags
  enable_telemetry = false
}

# Tools-FileShare
module "naming-fileshare" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = var.sub_component_file_share
}

module "rg-fileshare" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-fileshare.resource_group_name
  location         = module.metadata.metadata_object.region
  tags             = module.metadata.tags
  enable_telemetry = false
}

module "naming-fileshare-dr" {
  source        = "../../modules/naming"
  metadata      = module.metadata-dr.metadata_object
  sub_component = var.sub_component_file_share
}

module "rg-fileshare-dr" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-fileshare-dr.resource_group_name
  location         = module.metadata-dr.metadata_object.region
  tags             = module.metadata-dr.tags
  enable_telemetry = false
}

module "storage_account-fileshare" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                    = "Azure/avm-res-storage-storageaccount/azurerm"
  version                   = "0.5.0"
  name                      = module.naming-fileshare.storage_account_name
  resource_group_name       = module.rg-fileshare.name
  location                  = module.metadata.metadata_object.region
  shared_access_key_enabled = true
  tags                      = module.metadata.tags
  account_kind              = "FileStorage"
  account_tier              = "Premium"
  # This is a requirement for NFS shares as per https://learn.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer
  https_traffic_only_enabled = false
  diagnostic_settings_storage_account = {
    default-account : {
      name                  = "default-account"
      log_categories        = module.util.diagnostic_settings_helper.storage_account.log_categories
      metric_categories     = module.util.diagnostic_settings_helper.storage_account.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  diagnostic_settings_blob = {
    default-blob : {
      name                  = "default-blob"
      log_category_groups   = ["allLogs"]
      metric_categories     = module.util.diagnostic_settings_helper.storage_account_blob.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  diagnostic_settings_file = {
    default-file : {
      name                  = "default-file"
      log_category_groups   = ["allLogs"]
      metric_categories     = module.util.diagnostic_settings_helper.storage_account_file.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  network_rules = {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]

    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.MF_tenant_id
    }]
  }
  enable_telemetry = false

  private_endpoints = {
    file = {
      name                            = module.naming-fileshare.private_endpoint_names.storage_account.file
      subnet_resource_id              = module.virtual_network-tools.subnets["PrivateEndpoints2"].resource_id
      private_dns_zone_ids            = [var.storage_file_private_dns_zone_resource_id]
      subresource_name                = "file"
      private_dns_zone_resource_ids   = [var.storage_file_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-tools_vnet.virtual_network_name}"
      network_interface_name          = "${module.naming-fileshare.private_endpoint_names.storage_account.file}-nic"
      tags                            = module.metadata.tags
      ip_configurations = {
        file_default = {
          name               = "${module.naming-fileshare.private_endpoint_names.storage_account.file}-nic-ipconfig"
          private_ip_address = var.fileshare_storage_account_private_endpoint_ip
        }
      }
    }
  }

  managed_identities = {
    user_assigned_resource_ids = toset([module.user_assigned_managed_identity-foundational.resource_id])
  }

  customer_managed_key = {
    key_name              = module.naming-fileshare.storage_account_name
    key_vault_resource_id = module.key_vault.resource_id
    user_assigned_identity = {
      resource_id = module.user_assigned_managed_identity-foundational.resource_id
    }
  }

  depends_on = [module.provider_registration]
}

resource "azurerm_management_lock" "storage_account_fileshare_lock" {
  provider   = azurerm.azurerm_application_provider
  name       = "${module.naming-fileshare.storage_account_name}-lock"
  scope      = module.storage_account-fileshare.resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is to prevent accidental deletion of the fileshare storage account."
  depends_on = [module.storage_account-fileshare]
}

module "private_endpoint_fileshare_dr" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source = "../../modules/private_endpoint"

  location                                 = module.metadata-dr.metadata_object.region
  Resource_Group_name                      = module.rg-fileshare.name
  tags                                     = module.metadata-dr.tags
  private_endpoint_name                    = "${module.naming-fileshare-dr.recovery_services_vault_name}-siterecovery-pe"
  private_resource_id                      = module.storage_account-fileshare.resource_id
  private_endpoint_subnet_id               = module.virtual_network-tools-ce.subnets["PrivateEndpoints2"].resource_id
  private_endpoint_virtual_network_name    = module.virtual_network-tools-ce.name
  private_endpoint_service_connection_name = module.virtual_network-tools-ce.name
  subresource_names                        = ["file"]
  add_dns_zone_vnet_link                   = false
  private_endpoints_ip_configurations = {
    file = {
      "name" : "${module.naming-fileshare-dr.recovery_services_vault_name}-siterecovery-pe-blob-pe-ipconfig",
      "private_ip_address" : var.fileshare_storage_account_private_endpoint_dr_ip,
      "subresource_name" : "file",
      "member_name" : "file"
    }
  }
  private_endpoint_virtual_network_id = module.virtual_network-tools-ce.resource_id

  depends_on = [module.rg-foundation]
}

module "storage_account-fileshare-dr" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                    = "Azure/avm-res-storage-storageaccount/azurerm"
  version                   = "0.5.0"
  name                      = module.naming-fileshare-dr.storage_account_name
  resource_group_name       = module.rg-fileshare-dr.name
  location                  = module.metadata-dr.metadata_object.region
  shared_access_key_enabled = true
  account_replication_type  = "LRS"
  tags                      = module.metadata-dr.tags
  account_kind              = "FileStorage"
  account_tier              = "Premium"
  # This is a requirement for NFS shares as per https://learn.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer
  https_traffic_only_enabled = false
  diagnostic_settings_storage_account = {
    default-account : {
      name                  = "default-account"
      log_categories        = module.util.diagnostic_settings_helper.storage_account.log_categories
      metric_categories     = module.util.diagnostic_settings_helper.storage_account.metric_categories
      workspace_resource_id = module.log_analytics_workspace-ce.resource_id
    }
  }
  diagnostic_settings_blob = {
    default-blob : {
      name                  = "default-blob"
      log_category_groups   = ["allLogs"]
      metric_categories     = module.util.diagnostic_settings_helper.storage_account_blob.metric_categories
      workspace_resource_id = module.log_analytics_workspace-ce.resource_id
    }
  }
  diagnostic_settings_file = {
    default-file : {
      name                  = "default-file"
      log_category_groups   = ["allLogs"]
      metric_categories     = module.util.diagnostic_settings_helper.storage_account_file.metric_categories
      workspace_resource_id = module.log_analytics_workspace-ce.resource_id
    }
  }
  network_rules = {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]

    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.MF_tenant_id
    }]
  }
  enable_telemetry = false

  private_endpoints = {
    file = {
      name                            = module.naming-fileshare-dr.private_endpoint_names.storage_account.file
      subnet_resource_id              = module.virtual_network-tools-ce.subnets["PrivateEndpoints2"].resource_id
      private_dns_zone_ids            = [var.storage_file_private_dns_zone_resource_id]
      subresource_name                = "file"
      private_dns_zone_resource_ids   = [var.storage_file_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-tools_vnet-ce.virtual_network_name}"
      network_interface_name          = "${module.naming-fileshare-dr.private_endpoint_names.storage_account.file}-nic"
      tags                            = module.metadata-dr.tags
      ip_configurations = {
        file_default = {
          name               = "${module.naming-fileshare-dr.private_endpoint_names.storage_account.file}-nic-ipconfig"
          private_ip_address = var.secondary_fileshare_storage_account_private_endpoint_ip
        }
      }
    }
  }

  managed_identities = {
    user_assigned_resource_ids = toset([module.user_assigned_managed_identity-foundational-ce.resource_id])
  }

  customer_managed_key = {
    key_name              = module.naming-fileshare-dr.storage_account_name
    key_vault_resource_id = module.key_vault-ce.resource_id
    user_assigned_identity = {
      resource_id = module.user_assigned_managed_identity-foundational-ce.resource_id
    }
  }

  depends_on = [module.provider_registration]
}

resource "azurerm_management_lock" "storage_account_fileshare_dr_lock" {
  provider   = azurerm.azurerm_application_provider
  name       = "${module.naming-fileshare-dr.storage_account_name}-lock"
  scope      = module.storage_account-fileshare-dr.resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is to prevent accidental deletion of the fileshare dr storage account."
  depends_on = [module.storage_account-fileshare-dr]
}

# SmartShift Tool
module "naming-smartshift" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = var.sub_component_smartshift
}

module "rg-smartshift" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-smartshift.resource_group_name
  location         = module.metadata.metadata_object.region
  tags             = module.metadata.tags
  enable_telemetry = false
}

# Deployment
module "naming-deployment" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = var.sub_component_deployment
}

module "rg-deployment" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-deployment.resource_group_name
  location         = module.metadata.metadata_object.region
  tags             = module.metadata.tags
  enable_telemetry = false
}

resource "azurerm_role_assignment" "group-deployment-contribugor" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = module.security_group["MF-SAP-Infra-PPR-AAD-GRP"].security_group_object_id
  role_definition_name = "Contributor"
  scope                = module.rg-deployment.resource_id
  principal_type       = "Group"
}

# Solman Dev
module "naming-solman-dev" {
  source        = "../../modules/naming"
  metadata      = module.metadata-dev.metadata_object
  sub_component = var.sub_component_solman
}

module "rg-solman-dev" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-solman-dev.resource_group_name
  location         = module.metadata-dev.metadata_object.region
  tags             = module.metadata-dev.tags
  enable_telemetry = false
}

# Solman Prod
module "naming-solman" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = var.sub_component_solman
}

module "rg-solman" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-solman.resource_group_name
  location         = module.metadata.metadata_object.region
  tags             = module.metadata.tags
  enable_telemetry = false
}

module "naming-solman-prod" {
  source        = "../../modules/naming"
  metadata      = module.metadata-prod.metadata_object
  sub_component = var.sub_component_solman
}

module "rg-solman-prod" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-solman-prod.resource_group_name
  location         = module.metadata-prod.metadata_object.region
  tags             = module.metadata-prod.tags
  enable_telemetry = false
}

# Solman DR
module "naming-solman-dr" {
  source        = "../../modules/naming"
  metadata      = module.metadata-dr.metadata_object
  sub_component = var.sub_component_solman
}

module "rg-solman-dr" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-solman-dr.resource_group_name
  location         = module.metadata-dr.metadata_object.region
  tags             = module.metadata-dr.tags
  enable_telemetry = false
}

# Deployment DR
module "naming-deployment-dr" {
  source        = "../../modules/naming"
  metadata      = module.metadata-dr.metadata_object
  sub_component = var.sub_component_deployment
}

module "rg-deployment-dr" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-deployment-dr.resource_group_name
  location         = module.metadata-dr.metadata_object.region
  tags             = module.metadata-dr.tags
  enable_telemetry = false
}

# Application Gateway
module "naming-app_gateway" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = var.sub_component_app_gateway
}

module "rg-app_gateway" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-app_gateway.resource_group_name
  location         = module.metadata.metadata_object.region
  tags             = module.metadata.tags
  enable_telemetry = false
}

# Web Dispatcher
module "naming-web_dispatcher" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = var.sub_component_web_dispatcher
}

module "rg-web_dispatcher" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-web_dispatcher.resource_group_name
  location         = module.metadata.metadata_object.region
  tags             = module.metadata.tags
  enable_telemetry = false
}

# ASCS
module "naming-ascs" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = var.sub_component_ascs
}

module "rg-ascs" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-ascs.resource_group_name
  location         = module.metadata.metadata_object.region
  tags             = module.metadata.tags
  enable_telemetry = false
}

# SRM
module "naming-srm" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = var.sub_component_srm
}

module "rg-srm" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-srm.resource_group_name
  location         = module.metadata.metadata_object.region
  tags             = module.metadata.tags
  enable_telemetry = false
}

# BW
module "naming-bw" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = var.sub_component_bw
}

module "rg-bw" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-bw.resource_group_name
  location         = module.metadata.metadata_object.region
  tags             = module.metadata.tags
  enable_telemetry = false
}

# Portal
module "naming-portal" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = var.sub_component_portal
}

module "rg-portal" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-portal.resource_group_name
  location         = module.metadata.metadata_object.region
  tags             = module.metadata.tags
  enable_telemetry = false
}

module "security_group" {
  providers = {
    azuread.azuread_mccaingroup_onmicrosoft_com = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source      = "../../modules/security_group"
  for_each    = var.ad_groups
  owner_upn   = var.ad_groups_owner
  name        = each.value.name
  description = each.value.description
  member_upns = each.value.member_upns
}

resource "azurerm_role_assignment" "policy_spn_roles" {
  provider             = azurerm.azurerm_application_provider
  for_each             = var.policy_spn_roles
  principal_id         = each.value.spn_object_id
  role_definition_name = each.value.role_name
  scope                = each.value.scope
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "policy_group_roles" {
  provider             = azurerm.azurerm_application_provider
  for_each             = var.policy_group_roles
  principal_id         = module.security_group[each.value.group_identifier].security_group_object_id
  role_definition_name = each.value.role_name
  scope                = each.value.scope
  principal_type       = "Group"
}

# Deployment
module "naming-cloud_builder_identity" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = "Cloud Builder"
}

module "naming-cloud_builder_identity-ce" {
  source        = "../../modules/naming"
  metadata      = module.metadata-dr.metadata_object
  sub_component = "Cloud Builder"
}

module "user_assigned_managed_identity_cloud_builder" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.3.3"
  name                = module.naming-cloud_builder_identity.user_assigned_managed_identity_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata.metadata_object.region
  tags                = module.metadata.tags
  enable_telemetry    = false
}

module "user_assigned_managed_identity_cloud_builder-ce" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.3.3"
  name                = module.naming-cloud_builder_identity-ce.user_assigned_managed_identity_name
  resource_group_name = module.rg-foundation-ce.name
  location            = module.metadata-dr.metadata_object.region
  tags                = module.metadata-dr.tags
  enable_telemetry    = false
}

resource "azurerm_role_assignment" "mi-foundation" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = module.user_assigned_managed_identity_cloud_builder.principal_id
  role_definition_name = "Contributor"
  scope                = module.rg-foundation.resource_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "mi-foundation-ce" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = module.user_assigned_managed_identity_cloud_builder-ce.principal_id
  role_definition_name = "Contributor"
  scope                = module.rg-foundation-ce.resource_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "foundatinal-mi-kv-encryption" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = module.user_assigned_managed_identity-foundational.principal_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  scope                = module.rg-foundation.resource_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "foundatinal-mi-ce-kv-encryption" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = module.user_assigned_managed_identity-foundational-ce.principal_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  scope                = module.rg-foundation-ce.resource_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "mi-worklaod" {
  provider = azurerm.azurerm_application_provider
  for_each = {
    "1"  = module.rg-fileshare
    "2"  = module.rg-deployment
    "3"  = module.rg-solman
    "4"  = module.rg-app_gateway
    "5"  = module.rg-web_dispatcher
    "6"  = module.rg-ascs
    "7"  = module.rg-srm
    "8"  = module.rg-bw
    "9"  = module.rg-portal
    "10" = module.rg-solman-dev
    "11" = module.rg-solman-prod
  }
  principal_id         = module.user_assigned_managed_identity_cloud_builder.principal_id
  role_definition_name = "Contributor"
  scope                = each.value.resource_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "mi-worklaod-ce" {
  provider = azurerm.azurerm_application_provider
  for_each = {
    "1" = module.rg-fileshare-dr
    "2" = module.rg-deployment-dr
    "3" = module.rg-solman-dr
  }
  principal_id         = module.user_assigned_managed_identity_cloud_builder-ce.principal_id
  role_definition_name = "Contributor"
  scope                = each.value.resource_id
  principal_type       = "ServicePrincipal"
}

module "virtual_machine-cloudbuilder" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-compute-virtualmachine/azurerm"
  version             = "0.18.1"
  name                = module.naming-cloud_builder_identity.virtual_machine_name
  resource_group_name = module.rg-deployment.name
  location            = module.metadata.metadata_object.region
  tags                = module.metadata.tags
  enable_telemetry    = false
  zone                = "1"
  sku_size            = var.cloud_builder_sku_size
  network_interfaces = {
    default = {
      name = "${module.naming-cloud_builder_identity.virtual_machine_name}-nic"
      ip_configurations = {
        private = {
          name                          = "${module.naming-cloud_builder_identity.virtual_machine_name}-nic-ipconfig"
          create_public_ip_address      = false
          is_primary_ipconfiguration    = true
          private_ip_address            = var.cloud_builder_private_ip
          private_ip_address_allocation = "Static"
          private_ip_subnet_resource_id = module.virtual_network-tools.subnets["Deployment"].resource_id
        }
      }
      accelerated_networking_enabled = true
      tags                           = module.metadata.tags

      diagnostic_settings = {
        default = {
          name                  = "default-base"
          workspace_resource_id = module.log_analytics_workspace.resource_id
        }
      }
    }
  }

  encryption_at_host_enabled = false

  admin_password   = var.cloud_builder_admin_password
  admin_username   = var.cloud_builder_admin_username
  boot_diagnostics = true
  computer_name    = var.cloud_builder_computer_name

  diagnostic_settings = {
    default = {
      name                  = "default-base"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  managed_identities = {
    user_assigned_resource_ids = [
      module.user_assigned_managed_identity_cloud_builder.resource_id,
      module.user_assigned_managed_identity_cloud_builder-ce.resource_id,
      # TODO: Remove this once the temporary copy activity is finished and pre-prod backup and Binary storage accounts are recreated
      "/subscriptions/5de45b43-b8fc-4f60-81f8-ff5f29091c21/resourceGroups/mf-sap-foundation-ppr-cc-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mf-sap-strcopy-temp-ppr-cc-mi"
    ]
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  os_type = "Linux"

  source_image_reference = {
    publisher = var.cloud_builder_image_publisher
    offer     = var.cloud_builder_image_offer
    sku       = var.cloud_builder_image_sku
    version   = var.cloud_builder_image_version
  }

}

# SmartShift VM
module "naming-smartshift_server" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = "SmartShift Server"
}

module "virtual_machine-smartshift_server" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-compute-virtualmachine/azurerm"
  version             = "0.18.1"
  name                = module.naming-smartshift_server.virtual_machine_name
  resource_group_name = module.rg-smartshift.name
  location            = module.metadata.metadata_object.region
  tags                = module.metadata.tags
  enable_telemetry    = false
  zone                = "1"
  sku_size            = var.smartshift_server_sku_size
  network_interfaces = {
    default = {
      name = "${module.naming-smartshift_server.virtual_machine_name}-nic"
      ip_configurations = {
        private = {
          name                          = "${module.naming-smartshift_server.virtual_machine_name}-nic-ipconfig"
          create_public_ip_address      = false
          is_primary_ipconfiguration    = true
          private_ip_address            = var.smartshift_server_private_ip
          private_ip_address_allocation = "Static"
          private_ip_subnet_resource_id = module.virtual_network-tools.subnets["smartshift"].resource_id
        }
      }
      accelerated_networking_enabled = true
      tags                           = module.metadata.tags

      diagnostic_settings = {
        default = {
          name                  = "default-base"
          workspace_resource_id = module.log_analytics_workspace.resource_id
        }
      }
    }
  }

  encryption_at_host_enabled = false

  admin_password   = var.smartshift_server_admin_password
  admin_username   = var.smartshift_server_admin_username
  boot_diagnostics = true
  computer_name    = var.smartshift_server_computer_name

  diagnostic_settings = {
    default = {
      name                  = "default-base"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  data_disk_managed_disks = {
    disk1 = {
      name                 = "MF-CC-SAPSST-PPR_Disk"
      storage_account_type = "Premium_LRS"
      lun                  = 10
      caching              = "ReadWrite"
      disk_size_gb         = 256
      # disk_encryption_set_id = azurerm_disk_encryption_set.this.id
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 256
  }

  os_type = "Windows"

  source_image_reference = {
    publisher = var.smartshift_server_image_info.publisher
    offer     = var.smartshift_server_image_info.offer
    sku       = var.smartshift_server_image_info.sku
    version   = var.smartshift_server_image_info.version
  }
  azure_backup_configurations = {
    default = {
      recovery_vault_resource_id = module.recovery_services_vault.recovery_services_vault_id
      backup_policy_resource_id  = module.recovery_services_vault.recovery_services_vm_policy_ids["Default"]
    }
  }

}

module "naming-jump_server" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = "Jump Server"
}

module "virtual_machine-jump_server" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-compute-virtualmachine/azurerm"
  version             = "0.18.1"
  name                = module.naming-jump_server.virtual_machine_name
  resource_group_name = module.rg-deployment.name
  location            = module.metadata.metadata_object.region
  tags                = module.metadata.tags
  enable_telemetry    = false
  zone                = "1"
  sku_size            = var.jump_server_sku_size
  network_interfaces = {
    default = {
      name = "${module.naming-jump_server.virtual_machine_name}-nic"
      ip_configurations = {
        private = {
          name                          = "${module.naming-jump_server.virtual_machine_name}-nic-ipconfig"
          create_public_ip_address      = false
          is_primary_ipconfiguration    = true
          private_ip_address            = var.jump_server_private_ip
          private_ip_address_allocation = "Static"
          private_ip_subnet_resource_id = module.virtual_network-tools.subnets["Deployment"].resource_id
        }
      }
      accelerated_networking_enabled = true
      tags                           = module.metadata.tags

      diagnostic_settings = {
        default = {
          name                  = "default-base"
          workspace_resource_id = module.log_analytics_workspace.resource_id
        }
      }
    }
  }

  encryption_at_host_enabled = false

  admin_password   = var.jump_server_admin_password
  admin_username   = var.jump_server_admin_username
  boot_diagnostics = true
  computer_name    = var.jump_server_computer_name

  diagnostic_settings = {
    default = {
      name                  = "default-base"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  os_type = "Windows"

  source_image_reference = {
    publisher = var.jump_server_image_info.publisher
    offer     = var.jump_server_image_info.offer
    sku       = var.jump_server_image_info.sku
    version   = var.jump_server_image_info.version
  }
}

module "naming-binaries" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = "SAP Bin"
}

module "recovery_services_vault" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source              = "../../modules/recovery_services_vault"
  name                = module.naming-default.recovery_services_vault_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata.metadata_object.region
  tags                = module.metadata.tags
  vm_backup_policies  = var.vm_backup_policies
}

module "recovery_services_vault-ce" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source              = "../../modules/recovery_services_vault"
  name                = module.naming-default-ce.recovery_services_vault_name
  resource_group_name = module.rg-foundation-ce.name
  location            = module.metadata-dr.metadata_object.region
  tags                = module.metadata-dr.tags
  vm_backup_policies  = var.vm_backup_policies
}

module "naming-rsv" {
  source        = "../../modules/naming"
  metadata      = module.metadata-dr.metadata_object
  sub_component = "rsv"
}

module "recovery_services_vault-replication" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source                       = "../../modules/recovery_services_vault"
  name                         = module.naming-rsv.recovery_services_vault_name
  resource_group_name          = module.rg-foundation-ce.name
  location                     = module.metadata-dr.metadata_object.region
  storage_mode_type            = "GeoRedundant"
  tags                         = module.metadata-dr.tags
  vm_backup_policies           = var.vm_backup_policies
  cross_region_restore_enabled = true

  # Private endpoints for cross region recovery
  site_recovery_private_dns_zone_id                  = var.site_recovery_private_dns_zone_id
  site_recovery_private_dns_zone_name                = var.site_recovery_private_dns_zone_name
  private_endpoint_subnet_id                         = module.virtual_network-tools-ce.subnets["PrivateEndpoints"].resource_id
  private_endpoint_vnet_name                         = module.virtual_network-tools-ce.name
  private_endpoint_vnet_resource_id                  = module.virtual_network-tools-ce.resource_id
  add_site_recovery_dns_zone_vnet_link               = true
  site_recovery_private_dns_zone_resource_group_name = var.site_recovery_private_dns_zone_resource_group_name

  depends_on = [module.rg-foundation-ce]
}

# Azure Site recovery vault private endpoints for DR
module "private_endpoint_site_recovery" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source = "../../modules/private_endpoint"

  location                                 = module.metadata.metadata_object.region
  Resource_Group_name                      = module.rg-foundation.name
  tags                                     = module.metadata.tags
  private_endpoint_name                    = "${module.naming-rsv.recovery_services_vault_name}-siterecovery-pe"
  private_resource_id                      = module.recovery_services_vault-replication.recovery_services_vault_id
  private_endpoint_subnet_id               = module.virtual_network-tools.subnets["PrivateEndpoints"].resource_id
  private_endpoint_virtual_network_name    = module.virtual_network-tools.name
  private_endpoint_service_connection_name = module.virtual_network-tools.name
  subresource_names                        = ["AzureSiteRecovery"]
  add_dns_zone_vnet_link                   = false
  private_endpoints_ip_configurations      = {}
  private_endpoint_virtual_network_id      = module.virtual_network-tools.resource_id

  depends_on = [module.rg-foundation]
}

module "storage_account-binaries" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                    = "Azure/avm-res-storage-storageaccount/azurerm"
  version                   = "0.5.0"
  name                      = module.naming-binaries.storage_account_name
  resource_group_name       = module.rg-deployment.name
  location                  = module.metadata.metadata_object.region
  shared_access_key_enabled = true
  tags                      = module.metadata.tags
  diagnostic_settings_storage_account = {
    default-account : {
      name                  = "default-account"
      log_categories        = module.util.diagnostic_settings_helper.storage_account.log_categories
      metric_categories     = module.util.diagnostic_settings_helper.storage_account.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  diagnostic_settings_blob = {
    default-blob : {
      name                  = "default-blob"
      log_category_groups   = ["allLogs"]
      metric_categories     = module.util.diagnostic_settings_helper.storage_account_blob.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  network_rules = {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]

    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.MF_tenant_id
    }]
  }
  enable_telemetry = false

  private_endpoints = {
    blob = {
      name                            = module.naming-binaries.private_endpoint_names.storage_account.blob
      subnet_resource_id              = module.virtual_network-tools.subnets["PrivateEndpoints2"].resource_id
      private_dns_zone_ids            = [var.storage_blob_private_dns_zone_resource_id]
      subresource_name                = "blob"
      private_dns_zone_resource_ids   = [var.storage_blob_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-tools_vnet.virtual_network_name}"
      network_interface_name          = "${module.naming-binaries.private_endpoint_names.storage_account.blob}-nic"
      tags                            = module.metadata.tags
      ip_configurations = {
        blob_default = {
          name               = "${module.naming-binaries.private_endpoint_names.storage_account.blob}-nic-ipconfig"
          private_ip_address = var.binaries_storage_account_private_endpoint_ip
        }
      }
    }
  }

  blob_properties = {
    delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy = {
      days = var.blob_soft_delete_retention_days
    }
  }

  account_replication_type = "GRS"

  managed_identities = {
    user_assigned_resource_ids = toset([module.user_assigned_managed_identity-foundational.resource_id])
  }

  customer_managed_key = {
    key_name              = module.naming-binaries.storage_account_name
    key_vault_resource_id = module.key_vault.resource_id
    user_assigned_identity = {
      resource_id = module.user_assigned_managed_identity-foundational.resource_id
    }
  }

  depends_on = [module.provider_registration]
}

resource "azurerm_management_lock" "storage_account_binaries_lock" {
  provider   = azurerm.azurerm_application_provider
  name       = "${module.naming-binaries.storage_account_name}-lock"
  scope      = module.storage_account-binaries.resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is to prevent accidental deletion of the binaries storage account."
  depends_on = [module.storage_account-binaries]
}

module "user_assigned_managed_identity-binaries" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.3.3"
  name                = module.naming-binaries.user_assigned_managed_identity_name
  resource_group_name = module.rg-deployment.name
  location            = module.metadata.metadata_object.region
  tags                = module.metadata.tags
  enable_telemetry    = false
}

resource "azurerm_role_assignment" "mi-binaries-assignment" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = module.user_assigned_managed_identity-binaries.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage_account-binaries.resource_id
  principal_type       = "ServicePrincipal"
}

data "azuread_group" "binary_storage_contributor_groups" {
  provider     = azuread.azuread_mccaingroup_onmicrosoft_com
  for_each     = var.binaries_storage_account_contributor_access_groups
  display_name = each.value
}

resource "azurerm_role_assignment" "binarystorage_groups" {
  provider             = azurerm.azurerm_application_provider
  for_each             = var.binaries_storage_account_contributor_access_groups
  principal_id         = data.azuread_group.binary_storage_contributor_groups[each.key].object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = module.storage_account-binaries.resource_id
  principal_type       = "Group"
}

module "naming-replication" {
  source   = "../../modules/naming"
  metadata = module.metadata.metadata_object
  # Adding repl instead of rep as otherwise the DR environment
  sub_component = "asrreplcache"
}

resource "azurerm_management_lock" "storage_account_replication_lock" {
  provider   = azurerm.azurerm_application_provider
  name       = "${module.naming-replication.storage_account_name}-lock"
  scope      = module.storage_account-replication.resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is to prevent accidental deletion of the replication cache storage account."
  depends_on = [module.storage_account-replication]
}

module "storage_account-replication" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                        = "Azure/avm-res-storage-storageaccount/azurerm"
  version                       = "0.5.0"
  name                          = module.naming-replication.storage_account_name
  resource_group_name           = module.rg-foundation.name
  location                      = module.metadata.metadata_object.region
  shared_access_key_enabled     = false
  public_network_access_enabled = true
  tags                          = module.metadata.tags
  diagnostic_settings_storage_account = {
    default-account : {
      name                  = "default-account"
      log_categories        = module.util.diagnostic_settings_helper.storage_account.log_categories
      metric_categories     = module.util.diagnostic_settings_helper.storage_account.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  diagnostic_settings_blob = {
    default-blob : {
      name                  = "default-blob"
      log_category_groups   = ["allLogs"]
      metric_categories     = module.util.diagnostic_settings_helper.storage_account_blob.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  network_rules = {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]

    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.MF_tenant_id
    }]

    virtual_network_subnet_ids = [
      module.virtual_network-tools.subnets["Solman"].resource_id,
      module.virtual_network-tools.subnets["Solman-dev"].resource_id,
      module.virtual_network-tools.subnets["Deployment"].resource_id,
      module.virtual_network-tools.subnets["PrivateEndpoints"].resource_id,
      module.virtual_network-tools.subnets["PrivateEndpoints2"].resource_id
    ]
  }
  enable_telemetry = false

  private_endpoints = {
    blob = {
      name                            = module.naming-replication.private_endpoint_names.storage_account.blob
      subnet_resource_id              = module.virtual_network-tools.subnets["PrivateEndpoints2"].resource_id
      private_dns_zone_ids            = [var.storage_blob_private_dns_zone_resource_id]
      subresource_name                = "blob"
      private_dns_zone_resource_ids   = [var.storage_blob_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-tools_vnet.virtual_network_name}"
      network_interface_name          = "${module.naming-replication.private_endpoint_names.storage_account.blob}-nic"
      tags                            = module.metadata.tags
      ip_configurations = {
        blob_default = {
          name               = "${module.naming-replication.private_endpoint_names.storage_account.blob}-nic-ipconfig"
          private_ip_address = var.asr_replication_storage_account_private_endpoint_ip
        }
      }
    }
  }

  account_replication_type = "ZRS"

  managed_identities = {
    user_assigned_resource_ids = toset([module.user_assigned_managed_identity-foundational.resource_id])
  }

  customer_managed_key = {
    key_name              = module.naming-replication.storage_account_name
    key_vault_resource_id = module.key_vault.resource_id
    user_assigned_identity = {
      resource_id = module.user_assigned_managed_identity-foundational.resource_id
    }
  }

  depends_on = [module.provider_registration]
}

module "naming-replication-ce" {
  source        = "../../modules/naming"
  metadata      = module.metadata-dr.metadata_object
  sub_component = "asrreplcache"
}

resource "azurerm_management_lock" "storage_account_ce_replication_lock" {
  provider   = azurerm.azurerm_application_provider
  name       = "${module.naming-replication-ce.storage_account_name}-lock"
  scope      = module.storage_account-replication.resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is to prevent accidental deletion of the replication cache storage account."
  depends_on = [module.storage_account-replication-ce]
}

module "storage_account-replication-ce" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                        = "Azure/avm-res-storage-storageaccount/azurerm"
  version                       = "0.5.0"
  name                          = module.naming-replication-ce.storage_account_name
  resource_group_name           = module.rg-foundation-ce.name
  location                      = module.metadata-dr.metadata_object.region
  shared_access_key_enabled     = false
  public_network_access_enabled = true
  tags                          = module.metadata-dr.tags
  diagnostic_settings_storage_account = {
    default-account : {
      name                  = "default-account"
      log_categories        = module.util.diagnostic_settings_helper.storage_account.log_categories
      metric_categories     = module.util.diagnostic_settings_helper.storage_account.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  diagnostic_settings_blob = {
    default-blob : {
      name                  = "default-blob"
      log_category_groups   = ["allLogs"]
      metric_categories     = module.util.diagnostic_settings_helper.storage_account_blob.metric_categories
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
  network_rules = {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]

    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.MF_tenant_id
    }]

    virtual_network_subnet_ids = [
      module.virtual_network-tools-ce.subnets["Solman"].resource_id,
      module.virtual_network-tools-ce.subnets["Deployment"].resource_id,
      module.virtual_network-tools-ce.subnets["PrivateEndpoints"].resource_id,
      module.virtual_network-tools-ce.subnets["PrivateEndpoints2"].resource_id
    ]
  }
  enable_telemetry = false

  private_endpoints = {
    blob = {
      name                            = module.naming-replication-ce.private_endpoint_names.storage_account.blob
      subnet_resource_id              = module.virtual_network-tools-ce.subnets["PrivateEndpoints2"].resource_id
      private_dns_zone_ids            = [var.storage_blob_private_dns_zone_resource_id]
      subresource_name                = "blob"
      private_dns_zone_resource_ids   = [var.storage_blob_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-tools_vnet.virtual_network_name}"
      network_interface_name          = "${module.naming-replication-ce.private_endpoint_names.storage_account.blob}-nic"
      tags                            = module.metadata-dr.tags
      ip_configurations = {
        blob_default = {
          name               = "${module.naming-replication-ce.private_endpoint_names.storage_account.blob}-nic-ipconfig"
          private_ip_address = var.secondary_asr_replication_storage_account_private_endpoint_ip
        }
      }
    }
  }

  account_replication_type = "LRS"

  managed_identities = {
    user_assigned_resource_ids = toset([module.user_assigned_managed_identity-foundational-ce.resource_id])
  }

  customer_managed_key = {
    key_name              = module.naming-replication-ce.storage_account_name
    key_vault_resource_id = module.key_vault-ce.resource_id
    user_assigned_identity = {
      resource_id = module.user_assigned_managed_identity-foundational-ce.resource_id
    }
  }

  depends_on = [module.provider_registration]
}


# Appliction Security Group
module "metadata-asg" {
  source          = "../../modules/metadata"
  for_each        = var.application_security_group_names
  organization    = var.organization
  solution        = var.solution
  environment     = var.environment
  application     = each.value
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_owner
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date_tools
  modified_date   = var.modified_date_tools
  region          = var.region
}

module "naming-asg" {
  source   = "../../modules/naming"
  metadata = module.metadata-asg[each.key].metadata_object
  for_each = var.application_security_group_names
}

module "application_security_group" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source              = "../../modules/application_security_group"
  for_each            = var.application_security_group_names
  name                = module.naming-asg[each.key].application_security_group_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata.metadata_object.region
  tags                = module.metadata.tags
}

module "metadata-asg-dev" {
  source          = "../../modules/metadata"
  for_each        = var.dev_application_security_group_names
  organization    = var.organization
  solution        = var.solution
  environment     = var.environment-dev
  application     = each.value
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_owner
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date_tools
  modified_date   = var.modified_date_tools
  region          = var.region
}

module "naming-asg-dev" {
  source   = "../../modules/naming"
  metadata = module.metadata-asg-dev[each.key].metadata_object
  for_each = var.dev_application_security_group_names
}

module "application_security_group-dev" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source              = "../../modules/application_security_group"
  for_each            = var.dev_application_security_group_names
  name                = module.naming-asg-dev[each.key].application_security_group_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata-dev.metadata_object.region
  tags                = module.metadata-dev.tags
}

module "metadata-asg-prod" {
  source          = "../../modules/metadata"
  for_each        = var.prod_application_security_group_names
  organization    = var.organization
  solution        = var.solution
  environment     = var.environment-prod
  application     = each.value
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_owner
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date_tools
  modified_date   = var.modified_date_tools
  region          = var.region
}

module "naming-asg-prod" {
  source   = "../../modules/naming"
  metadata = module.metadata-asg-prod[each.key].metadata_object
  for_each = var.prod_application_security_group_names
}

module "application_security_group-prod" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source              = "../../modules/application_security_group"
  for_each            = var.prod_application_security_group_names
  name                = module.naming-asg-prod[each.key].application_security_group_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata-prod.metadata_object.region
  tags                = module.metadata-prod.tags
}

### Secondary region ### Canada East ###
module "metadata-secondary" {
  source          = "../../modules/metadata"
  organization    = var.organization
  solution        = var.solution
  environment     = var.environment
  application     = var.application
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_owner
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date_tools
  modified_date   = var.modified_date_tools
  region          = var.secondary_region
}

module "metadata-asg-dr" {
  source          = "../../modules/metadata"
  for_each        = var.application_security_group_names
  organization    = var.organization
  solution        = var.solution
  environment     = var.environment-dr
  application     = each.value
  gl_code         = var.gl_code
  it_owner        = var.it_owner
  business_owner  = var.business_owner
  iac_creator     = var.iac_creator
  iac_owner       = var.iac_owner
  network_posture = var.network_posture
  built_using     = var.built_using
  terraform_id    = var.terraform_id
  onboarding_date = var.onboarding_date_tools
  modified_date   = var.modified_date_tools
  region          = var.secondary_region
}

module "naming-asg-dr" {
  source   = "../../modules/naming"
  metadata = module.metadata-asg-dr[each.key].metadata_object
  for_each = var.application_security_group_names
}

module "application_security_group-dr" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source              = "../../modules/application_security_group"
  for_each            = var.application_security_group_names
  name                = module.naming-asg-dr[each.key].application_security_group_name
  resource_group_name = module.rg-foundation-ce.name
  location            = module.metadata-dr.metadata_object.region
  tags                = module.metadata-dr.tags
}

# Foundational
module "naming-foundational-ce" {
  source                   = "../../modules/naming"
  metadata                 = module.metadata-secondary.metadata_object
  is_foundational_resource = true
}

module "rg-foundation-ce" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  name             = module.naming-foundational-ce.resource_group_name
  location         = module.metadata-secondary.metadata_object.region
  tags             = module.metadata-secondary.tags
  enable_telemetry = false
}

##Secondary virtual network ##
module "naming-tools_vnet-ce" {
  source        = "../../modules/naming"
  metadata      = module.metadata-secondary.metadata_object
  sub_component = "Monitoring Tools"
}

module "virtual_network-tools-ce" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.8.1"
  name                = module.naming-tools_vnet-ce.virtual_network_name
  resource_group_name = module.rg-foundation-ce.name
  location            = module.metadata-secondary.metadata_object.region
  address_space       = toset(var.tools_vnet_address_spaces_secondary)

  diagnostic_settings = {
    "default" : {
      name                  = "default"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }

  # peerings = {
  #   "hub": {
  #     name = "${module.naming-tools_vnet.virtual_network_name}-${var.hub_vnet_name}"
  #     remote_virtual_network_resource_id = var.hub_vnet_id
  #     allow_virtual_network_access = true
  #     allow_forwarded_traffic = true
  #     create_reverse_peering = true
  #     reverse_name = "${var.hub_vnet_name}-${module.naming-tools_vnet.virtual_network_name}"
  #     allow_gateway_transit = false
  #     use_remote_gateways = false
  #   }
  # }

  subnets = { for k, subnet_info in var.tools_vnet_subnets_secondary : "${k}" => {
    name           = subnet_info.name
    address_prefix = subnet_info.address_prefix
    network_security_group = {
      id = module.network_security_groups_secondary[subnet_info.network_security_group].resource_id
    }
    route_table = {
      id = module.route_tables_secondary[subnet_info.route_table].resource_id
    }
    service_endpoints = ["Microsoft.Storage"]
    }
  }

  dns_servers = {
    dns_servers = toset(var.dns_servers)
  }

  tags             = module.metadata-secondary.tags
  enable_telemetry = false
}

module "custom_role-clustering" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source                               = "../../modules/custom_role"
  role_name                            = var.cluster_role_name
  description                          = var.cluster_role_description
  actions                              = var.cluster_role_actions
  assignable_scopes                    = var.cluster_role_assignable_scopes
  role_definition_location_resource_id = var.cluster_role_role_definition_location_resource_id
}

resource "azurerm_role_assignment" "cluster-spn-assignment" {
  provider = azurerm.azurerm_application_provider
  for_each = {
    "1"  = module.rg-fileshare
    "2"  = module.rg-deployment
    "3"  = module.rg-solman
    "4"  = module.rg-app_gateway
    "5"  = module.rg-web_dispatcher
    "6"  = module.rg-ascs
    "7"  = module.rg-srm
    "8"  = module.rg-bw
    "9"  = module.rg-portal
    "10" = module.rg-solman-dev
    "11" = module.rg-solman-prod
  }
  principal_id       = var.cluster_spn_object_id
  role_definition_id = module.custom_role-clustering.role_definition_resource_id
  scope              = each.value.resource_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "ad_groups_support_assignments" {
  provider             = azurerm.azurerm_application_provider
  for_each             = var.ad_groups
  principal_id         = module.security_group[each.key].security_group_object_id
  role_definition_name = "Support Request Contributor"
  scope                = "/subscriptions/${var.subscription_id}"
  principal_type       = "Group"
}

# foundational_rg_roles
resource "azurerm_role_assignment" "ad_groups_foundational_assignments" {
  provider             = azurerm.azurerm_application_provider
  for_each             = local.ad_group_foundational_role_assignments_map
  principal_id         = module.security_group[each.value.group_key].security_group_object_id
  role_definition_name = each.value.role_name
  scope                = module.rg-foundation.resource_id
  principal_type       = "Group"
}

# application_rg_roles
resource "azurerm_role_assignment" "ad_groups_application_rg_assignments" {
  provider             = azurerm.azurerm_application_provider
  for_each             = local.rg_ad_group_application_rg_role_assignments_map
  principal_id         = module.security_group[each.value.group_key].security_group_object_id
  role_definition_name = each.value.role_name
  scope                = each.value.scope
  principal_type       = "Group"
}

# application_rg_custom_roles
resource "azurerm_role_assignment" "ad_groups_application_rg_custom_role_assignments" {
  provider           = azurerm.azurerm_application_provider
  for_each           = local.rg_ad_group_application_rg_custom_role_assignments_map
  principal_id       = module.security_group[each.value.group_key].security_group_object_id
  role_definition_id = each.value.role_id
  scope              = each.value.scope
  principal_type     = "Group"
}

resource "time_static" "pim_time" {}

# application_rg_pim_builtin_roles
data "azurerm_role_definition" "app_rg_builtin" {
  provider = azurerm.azurerm_application_provider
  for_each = local.rg_ad_group_app_rg_pim_builtin_role_assignments_map
  name     = each.value.role_name
  scope    = "/subscriptions/${var.subscription_id}"
}

resource "azurerm_pim_eligible_role_assignment" "app_ad_group_pim_builtin_role_assignments" {
  provider = azurerm.azurerm_application_provider
  for_each = local.rg_ad_group_app_rg_pim_builtin_role_assignments_map

  scope              = each.value.scope
  role_definition_id = data.azurerm_role_definition.app_rg_builtin[each.key].id
  principal_id       = module.security_group[each.value.group_key].security_group_object_id

  schedule {
    start_date_time = time_static.pim_time.rfc3339
    expiration {
      duration_hours = 8
    }
  }
}

# application_rg_pim_custom_roles
data "azurerm_role_definition" "app_rg_custom" {
  provider           = azurerm.azurerm_application_provider
  for_each           = local.rg_ad_group_app_rg_pim_custom_role_assignments_map
  role_definition_id = each.value.role_id
  scope              = "/subscriptions/${var.subscription_id}"
}

resource "azurerm_pim_eligible_role_assignment" "app_ad_group_pim_custom_role_assignments" {
  provider = azurerm.azurerm_application_provider
  for_each = local.rg_ad_group_app_rg_pim_custom_role_assignments_map

  scope              = each.value.scope
  role_definition_id = data.azurerm_role_definition.app_rg_custom[each.key].id
  principal_id       = module.security_group[each.value.group_key].security_group_object_id

  schedule {
    start_date_time = time_static.pim_time.rfc3339
    expiration {
      duration_days = 365
    }
  }
}
