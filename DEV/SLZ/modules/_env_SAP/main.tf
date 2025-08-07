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
  onboarding_date = var.onboarding_date
  modified_date   = var.modified_date
  region          = var.region
}

# Helper
module "util" {
  source = "../../modules/util"
}

module "naming-default" {
  source   = "../../modules/naming"
  metadata = module.metadata.metadata_object
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
    "Microsoft.Storage", "Microsoft.Network", "Microsoft.OperationalInsights", "Microsoft.KeyVault",
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

module "naming-replication" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = "asrrepcache"
}

resource "azurerm_management_lock" "storage_account_replication_lock" {
  count      = var.environment == "Production" || var.environment == "Disaster Recovery" ? 1 : 0
  provider   = azurerm.azurerm_application_provider
  name       = "${module.naming-replication.storage_account_name}-lock"
  scope      = module.storage_account-replication["1"].resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is to prevent accidental deletion of the replication cache storage account."
  depends_on = [module.storage_account-replication]
}

module "storage_account-replication" {
  for_each = var.environment == "Production" ? { "1" : "1" } : (var.environment == "Disaster Recovery" ? { "1" : "1" } : {})
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source                        = "Azure/avm-res-storage-storageaccount/azurerm"
  version                       = "0.5.0"
  name                          = module.naming-replication.storage_account_name
  resource_group_name           = module.rg-foundation.name
  location                      = module.metadata.metadata_object.region
  account_tier                  = "Premium"
  account_kind                  = "BlockBlobStorage"
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
      module.virtual_network.subnets["Application"].resource_id,
      module.virtual_network.subnets["Database"].resource_id,
      module.virtual_network.subnets["PrivateEndpoints"].resource_id,
      module.virtual_network.subnets["AppGateway"].resource_id
    ]
  }
  enable_telemetry = false

  private_endpoints = {
    blob = {
      name                            = module.naming-replication.private_endpoint_names.storage_account.blob
      subnet_resource_id              = module.virtual_network.subnets["PrivateEndpoints"].resource_id
      private_dns_zone_ids            = [var.storage_blob_private_dns_zone_resource_id]
      subresource_name                = "blob"
      private_dns_zone_resource_ids   = [var.storage_blob_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-default.virtual_network_name}"
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

  account_replication_type = (var.environment == "Disaster Recovery" ? "LRS" : "ZRS")

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
  account_replication_type  = module.metadata.metadata_object.region == "canadaeast" ? "LRS" : (var.environment == "Production" ? "GRS" : "ZRS")
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
    bypass         = ["AzureServices"]

    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.MF_tenant_id
    }]
  }
  enable_telemetry = false

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
          name               = "${module.naming-backup.private_endpoint_names.storage_account.blob}-nic-ipconfig"
          private_ip_address = var.foundational_storage_account_private_endpoint_ip
        }
      }
    }
  }

  depends_on = [module.provider_registration]
}

resource "azurerm_management_lock" "lock-storage_account-foundational-delete" {
  name       = "${module.naming-foundational.storage_account_name}-lock"
  scope      = module.storage_account-foundational.resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is applied to the foundational storage account to prevent accidental deletion."
  provider   = azurerm.azurerm_application_provider
  depends_on = [module.storage_account-foundational]
}

resource "azurerm_management_lock" "lock-storage_account-backup-delete" {
  name       = "${module.naming-backup.storage_account_name}-lock"
  scope      = module.storage_account-backup.resource_id
  lock_level = "CanNotDelete"
  notes      = "This lock is applied to the backup storage account to prevent accidental deletion."
  provider   = azurerm.azurerm_application_provider
  depends_on = [module.storage_account-foundational]
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
  account_replication_type  = module.metadata.metadata_object.region == "canadaeast" ? "LRS" : (var.environment == "Production" ? "GRS" : "ZRS")
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
    bypass         = ["AzureServices"]

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

  depends_on = [module.provider_registration]
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

module "key_vault" {
  providers = {
    azurerm = azurerm.azurerm_application_provider
  }
  source              = "Azure/avm-res-keyvault-vault/azurerm"
  version             = "0.10.0"
  name                = var.environment == "Disaster Recovery" ? module.naming-dr.key_vault_name : module.naming-default.key_vault_name
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
      subnet_resource_id              = module.virtual_network.subnets["PrivateEndpoints"].resource_id
      private_dns_zone_ids            = [var.key_vault_private_dns_zone_resource_id]
      subresource_name                = "vault"
      private_dns_zone_resource_ids   = [var.key_vault_private_dns_zone_resource_id]
      private_service_connection_name = "${module.naming-default.virtual_network_name}"
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
  # }

  tags             = module.metadata.tags
  enable_telemetry = false
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

  # peerings = {
  #   "hub": {
  #     name = "${module.naming-default.virtual_network_name}-${var.hub_vnet_name}"
  #     remote_virtual_network_resource_id = var.hub_vnet_id
  #     allow_virtual_network_access = true
  #     allow_forwarded_traffic = true
  #     create_reverse_peering = true
  #     reverse_name = "${var.hub_vnet_name}-${module.naming-default.virtual_network_name}"
  #     allow_gateway_transit = false
  #     use_remote_gateways = false
  #   }
  # }

  peerings = {
    "monitoring" : {
      name                               = "${module.naming-default.virtual_network_name}-${var.monitoring_tools_vnet_name}"
      remote_virtual_network_resource_id = var.monitoring_tools_vnet_id
      allow_virtual_network_access       = true
      allow_forwarded_traffic            = true
      create_reverse_peering             = true
      reverse_name                       = "${var.monitoring_tools_vnet_name}-${module.naming-default.virtual_network_name}"
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

# module "network_watcher" {
#   source  = "Azure/avm-res-network-networkwatcher/azurerm"
#   version = "0.3.1"
#   network_watcher_name = "${module.naming-default.virtual_network_name}-nw"
#   network_watcher_id   = "${module.naming-default.virtual_network_name}-nw"
#   resource_group_name  = module.rg-foundation.name
#   location             = module.metadata.metadata_object.region

#   flow_logs = {
#     default = {
#       name                = "${module.naming-default.virtual_network_name}-flow-logs"
#       target_resource_id  = module.virtual_network.resource_id
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

# Solman
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

resource "azurerm_role_assignment" "mi-foundation" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = var.managed_identity_object_id
  role_definition_name = "Contributor"
  scope                = module.rg-foundation.resource_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "foundatinal-mi-kv-encryption" {
  provider             = azurerm.azurerm_application_provider
  principal_id         = module.user_assigned_managed_identity-foundational.principal_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  scope                = module.rg-foundation.resource_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "mi-worklaod" {
  provider = azurerm.azurerm_application_provider
  for_each = {
    "1" = module.rg-solman
    "2" = module.rg-srm
    "3" = module.rg-bw
    "4" = module.rg-portal
  }
  principal_id         = var.managed_identity_object_id
  role_definition_name = "Contributor"
  scope                = each.value.resource_id
  principal_type       = "ServicePrincipal"
}

module "naming-dr" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = "dr"
}

module "recovery_services_vault" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source              = "../../modules/recovery_services_vault"
  name                = var.environment == "Disaster Recovery" ? module.naming-dr.recovery_services_vault_name : module.naming-default.recovery_services_vault_name
  resource_group_name = module.rg-foundation.name
  location            = module.metadata.metadata_object.region
  tags                = module.metadata.tags
  vm_backup_policies  = var.vm_backup_policies
  storage_mode_type   = var.environment == "Disaster Recovery" ? "LocallyRedundant" : "GeoRedundant"

  depends_on = [module.rg-foundation]
}

module "private_endpoint-storage_account_sap_binaries" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source = "../../modules/private_endpoint"

  location                                 = module.metadata.metadata_object.region
  Resource_Group_name                      = module.rg-foundation.name
  tags                                     = module.metadata.tags
  private_endpoint_name                    = "${var.sap_binaries_storage_account_name}-pe"
  private_resource_id                      = var.sap_binaries_storage_account_id
  private_endpoint_subnet_id               = module.virtual_network.subnets["PrivateEndpoints"].resource_id
  private_endpoint_virtual_network_name    = var.hub_vnet_name
  private_endpoint_service_connection_name = module.virtual_network.resource.name
  subresource_names                        = ["blob"]
  private_endpoints_ip_configurations = {
    blob : {
      "name" : "${var.sap_binaries_storage_account_name}-blob-pe-ipconfig",
      "private_ip_address" : var.sap_binaries_storage_private_endpoint_ip,
      "subresource_name" : "blob",
      "member_name" : "blob"
    }
  }
  private_dns_zone_resource_group_name = var.storage_blob_private_dns_zone_resource_group_name
  private_endpoint_virtual_network_id  = module.virtual_network.resource_id
  add_dns_zone_vnet_link               = false

  depends_on = [module.rg-foundation]
}

module "private_endpoint-storage_account_fileshare" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source = "../../modules/private_endpoint"

  location                                 = module.metadata.metadata_object.region
  Resource_Group_name                      = module.rg-foundation.name
  tags                                     = module.metadata.tags
  private_endpoint_name                    = "${var.fileshare_storage_account_name}-pe"
  private_resource_id                      = var.fileshare_storage_account_id
  private_endpoint_subnet_id               = module.virtual_network.subnets["PrivateEndpoints"].resource_id
  private_endpoint_virtual_network_name    = var.hub_vnet_name
  private_endpoint_service_connection_name = module.virtual_network.resource.name
  subresource_names                        = ["file"]
  private_endpoints_ip_configurations = {
    blob : {
      "name" : "${var.fileshare_storage_account_name}-file-pe-ipconfig",
      "private_ip_address" : var.fileshare_storage_private_endpoint_ip,
      "subresource_name" : "file",
      "member_name" : "file"
    }
  }
  private_dns_zone_resource_group_name = var.storage_blob_private_dns_zone_resource_group_name
  private_endpoint_virtual_network_id  = module.virtual_network.resource_id
  add_dns_zone_vnet_link               = false

  depends_on = [module.rg-foundation]
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
  onboarding_date = var.onboarding_date
  modified_date   = var.modified_date
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


# module "start_stop_vm_role" {
#   providers = {
#     azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
#     azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
#     azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
#   }
#   source      = "../../modules/custom_role"
#   role_name   = var.role_name
#   description = var.description
#   core_infrastructure_subscription_id = var.core_infrastructure_subscription_id
#   scope       = "/subscriptions/${var.core_infrastructure_subscription_id}"

#   actions = [
#     "Microsoft.Compute/*/read",
#     "Microsoft.Compute/virtualMachines/start/action",
#     "Microsoft.Compute/virtualMachines/deallocate/action"
#   ]
#   principal_id       = module.app_registration.principal_id
# }

resource "azurerm_role_assignment" "cluster-spn-assignment" {
  provider = azurerm.azurerm_application_provider
  for_each = {
    "1" = module.rg-solman
    "2" = module.rg-srm
    "3" = module.rg-bw
    "4" = module.rg-portal
  }
  principal_id       = var.cluster_spn_object_id
  role_definition_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${var.cluster_role_definition_id}"
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
      duration_days = 365
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
      duration_hours = 8
    }
  }
}

# module "app_registration" {
#   providers = {
#     azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
#     azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
#     azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
#   }
#   source   = "../../modules/app_registration"
#   app_registration_name = var.app_registration_name
# }

# File share private endoint for Production
# TODO:

# Cross region Azure Site recovery vault for Production
module "naming-rsv" {
  source        = "../../modules/naming"
  metadata      = module.metadata.metadata_object
  sub_component = "rsv"
}

module "recovery_services_vault-production" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  for_each                     = var.environment == "Disaster Recovery" ? { "1" : "1" } : {}
  source                       = "../../modules/recovery_services_vault"
  name                         = module.naming-rsv.recovery_services_vault_name
  resource_group_name          = module.rg-foundation.name
  location                     = module.metadata.metadata_object.region
  storage_mode_type            = "GeoRedundant"
  tags                         = module.metadata.tags
  vm_backup_policies           = var.vm_backup_policies
  cross_region_restore_enabled = true

  # Private endpoints for cross region recovery
  site_recovery_private_dns_zone_id                  = var.site_recovery_private_dns_zone_id
  site_recovery_private_dns_zone_name                = var.site_recovery_private_dns_zone_name
  private_endpoint_subnet_id                         = module.virtual_network.subnets["PrivateEndpoints"].resource_id
  private_endpoint_vnet_name                         = module.virtual_network.name
  private_endpoint_vnet_resource_id                  = module.virtual_network.resource_id
  add_site_recovery_dns_zone_vnet_link               = true
  private_endpoint_ip_addresses                      = var.site_recovery_private_endpoint_ip_addresses
  site_recovery_private_dns_zone_resource_group_name = var.site_recovery_private_dns_zone_resource_group_name

  depends_on = [module.rg-foundation]
}

# Azure Site recovery vault private endpoints for DR
module "private_endpoint_site_recovery" {
  for_each = var.environment == "Production" ? { "1" : "1" } : {}
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
  private_resource_id                      = var.production_asr_vault_resource_id
  private_endpoint_subnet_id               = module.virtual_network.subnets["PrivateEndpoints"].resource_id
  private_endpoint_virtual_network_name    = module.virtual_network.name
  private_endpoint_service_connection_name = module.virtual_network.name
  subresource_names                        = ["AzureSiteRecovery"]
  add_dns_zone_vnet_link                   = false
  private_endpoints_ip_configurations      = {}
  private_endpoint_virtual_network_id      = module.virtual_network.resource_id

  depends_on = [module.rg-foundation]
}
