module "MF_MDI_CC_RG" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"
  providers = {
    azurerm = azurerm
  }
  name     = var.cc_resource_group.name
  location = var.cc_resource_group.location
  tags     = merge(local.tag_list_1, var.cc_resource_group.tags)
  role_assignments = {
    contributor_current_user = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Contributor"
    }
  }
  enable_telemetry = var.enable_telemetry
}

module "avm-res-network-virtualnetwork" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"
  providers = {
    azurerm = azurerm
  }
  enable_telemetry    = var.enable_telemetry
  address_space       = var.cc_vnet.address_space
  location            = var.cc_vnet.location
  name                = var.cc_vnet.name
  resource_group_name = module.MF_MDI_CC_RG.name
  tags                = local.tag_list_1
  subnets             = var.cc_vnet.subnets
  depends_on          = [module.nsg]

  peerings = {
    for k, v in {
      "hub" : {
        name                               = "${var.cc_vnet.name}-${var.hub_vnet_name}"
        remote_virtual_network_resource_id = var.hub_vnet_id
        allow_virtual_network_access       = true
        allow_forwarded_traffic            = true
        create_reverse_peering             = true
        reverse_name                       = "${var.hub_vnet_name}-${var.cc_vnet.name}"
        allow_gateway_transit              = false
        use_remote_gateways                = false
      }
  } : k => v if var.enable_peering }
}


module "nsg" {
  for_each = var.nsgs
  source   = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version  = "0.4.0"
  providers = {
    azurerm = azurerm
  }
  enable_telemetry    = var.enable_telemetry
  name                = each.key
  location            = each.value.location
  resource_group_name = module.MF_MDI_CC_RG.name
  security_rules      = length(each.value.security_rules) > 0 ? each.value.security_rules : var.domain_controller_default_nsg_rules
  tags                = local.tag_list_1
}

module "MF_MDI-rt" {
  for_each = var.route_tables
  source   = "Azure/avm-res-network-routetable/azurerm"
  version  = "0.4.1"
  providers = {
    azurerm = azurerm
  }
  enable_telemetry    = var.enable_telemetry
  name                = each.key
  location            = each.value.location
  resource_group_name = module.MF_MDI_CC_RG.name
  tags                = local.tag_list_1
  routes              = length(each.value.routes) > 0 ? each.value.routes : var.default_udr_routes
}

resource "random_password" "admin_password" {
  length           = 22
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  min_upper        = 2
  override_special = "!#$%&()*+,-./:;<=>?@[]^_{|}~"
  special          = true
}

resource "azurerm_user_assigned_identity" "mf-core-dc-uaid" {
  for_each            = var.user_assigned_identities
  location            = each.value.location
  name                = each.value.name
  resource_group_name = module.MF_MDI_CC_RG.name
  tags                = local.tag_list_1
}

resource "azurerm_role_assignment" "iac-spn-key-vault-officer-assignment" {
  provider             = azurerm
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Administrator"
  scope                = module.MF_MDI_CC_RG.resource_id
  principal_type       = "ServicePrincipal"
}

module "avm_res_keyvault_vault" {
  source              = "Azure/avm-res-keyvault-vault/azurerm"
  version             = "=0.10.0"
  for_each            = var.keyvaults
  location            = each.value.location
  name                = each.value.name
  resource_group_name = module.MF_MDI_CC_RG.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  enabled_for_disk_encryption = each.value.enabled_for_disk_encryption
  # keys                        = each.value.keys
  network_acls = {
    bypass = "AzureServices"
  }
  enabled_for_deployment        = true
  public_network_access_enabled = false
  soft_delete_retention_days    = 90
  # role_assignments = {
  #   deployment_user_secrets = { #give the deployment user access to secrets
  #     role_definition_id_or_name = "Key Vault Secrets Officer"
  #     principal_id               = data.azurerm_client_config.current.object_id
  #   }
  #   deployment_user_keys = { #give the deployment user access to keys
  #     role_definition_id_or_name = "Key Vault Crypto Officer"
  #     principal_id               = data.azurerm_client_config.current.object_id
  #   }
  #   user_managed_identity_keys = { #give the user assigned managed identity for the disk encryption set access to keys
  #     role_definition_id_or_name = "Key Vault Crypto Officer"
  #     principal_id               = azurerm_user_assigned_identity.mf-core-dc-uaid[var.identity_key].principal_id
  #     principal_type             = "ServicePrincipal"
  #   }
  # }
  private_endpoints = {
    vault = {
      name                            = "${each.value.name}-vault-pe"
      subnet_resource_id              = module.avm-res-network-virtualnetwork.subnets[var.private_endpoint_subnet_key].resource_id
      private_dns_zone_ids            = [var.key_vault_private_dns_zone_resource_id]
      subresource_name                = "vault"
      private_dns_zone_resource_ids   = [var.key_vault_private_dns_zone_resource_id]
      private_service_connection_name = "${var.cc_vnet.name}"
      network_interface_name          = "${each.value.name}-vault-pe-nic"
      tags                            = local.tag_list_1
    }
  }
  enable_telemetry                       = var.enable_telemetry
  tags                                   = local.tag_list_1
  wait_for_rbac_before_key_operations    = each.value.wait_for_rbac_before_key_operations
  wait_for_rbac_before_secret_operations = each.value.wait_for_rbac_before_secret_operations
}

# resource "azurerm_disk_encryption_set" "this" {
#   location            = var.disk_encryption_sets.location
#   name                = var.disk_encryption_sets.name
#   resource_group_name = module.MF_MDI_CC_RG.name
#   key_vault_key_id    = module.avm_res_keyvault_vault[var.key_vault_key].keys_resource_ids[var.disk_encryption_set_config_key].id
#   tags                = local.tag_list_1

#   identity {
#     type         = "UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.mf-core-dc-uaid[var.identity_key].id]
#   }
# }

module "avm-res-compute-virtualmachine" {
  for_each                   = var.virtual_machine_configs
  source                     = "Azure/avm-res-compute-virtualmachine/azurerm"
  version                    = "0.19.3"
  resource_group_name        = module.MF_MDI_CC_RG.name
  zone                       = each.value.zone
  network_interfaces         = each.value.network_interfaces
  name                       = each.value.name
  location                   = each.value.location
  encryption_at_host_enabled = each.value.encryption_at_host_enabled
  computer_name              = each.value.computer_name
  account_credentials = {
    admin_credentials = {
      username                           = each.value.account_credentials_adcredusername
      password                           = random_password.admin_password.result
      generate_admin_password_or_ssh_key = false
    }
    # key_vault_configuration = {
    #   resource_id = module.avm_res_keyvault_vault[var.key_vault_key].resource_id
    # }
  }
  managed_identities = {
    system_assigned = true
  }
  data_disk_managed_disks = {
    disk1 = {
      name                 = each.value.ddms_name
      storage_account_type = each.value.ddms_storage_account_type
      lun                  = each.value.ddms_lun
      caching              = each.value.ddms_caching
      disk_size_gb         = each.value.ddms_disk_size_gb
      # disk_encryption_set_id = azurerm_disk_encryption_set.this.id
    }
  }
  enable_telemetry = var.enable_telemetry
  os_disk = {
    caching              = each.value.ddms_caching
    storage_account_type = each.value.ddms_storage_account_type
    # disk_encryption_set_id = azurerm_disk_encryption_set.this.id
  }
  os_type                = each.value.os_type
  sku_size               = each.value.sku_size
  source_image_reference = each.value.source_image_reference
  patch_mode             = "AutomaticByPlatform"
  extensions             = local.encoded_vm_extensions[each.key]
  tags                   = local.tag_list_1

  azure_backup_configurations = {
    default = {
      recovery_vault_resource_id = module.recovery_services_vault.recovery_services_vault_id
      backup_policy_resource_id  = module.recovery_services_vault.vm_backup_policy_ids[var.backup_policy_identifier]
    }
  }

  depends_on = [module.avm-res-network-virtualnetwork]
}

###### Backup ####################

module "recovery_services_vault" {
  providers = {
    azurerm.azurerm_application_provider         = azurerm
    azurerm.azurerm_core_infrastructure_provider = azurerm
  }
  source              = "./modules/recovery_services_vault"
  name                = var.recovery_vault_config.name
  resource_group_name = module.MF_MDI_CC_RG.name
  location            = var.recovery_vault_config.location
  tags                = local.tag_list_1
  vm_backup_policies  = var.recovery_vault_config.vm_backup_policy
  storage_mode_type   = var.recovery_vault_config.storage_mode_type
  depends_on          = [module.MF_MDI_CC_RG]
}

module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.4.2"

  name                = var.log_analytics_workspace.name
  location            = var.log_analytics_workspace.location
  resource_group_name = module.MF_MDI_CC_RG.name
  enable_telemetry    = var.enable_telemetry
  tags                = local.tag_list_1
}

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.5.0"

  account_replication_type          = var.storage_account.account_replication_type
  location                          = var.storage_account.location
  name                              = var.storage_account.name
  resource_group_name               = module.MF_MDI_CC_RG.name
  infrastructure_encryption_enabled = true

  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.mf-core-dc-uaid[var.identity_key].id]
  }

  # customer_managed_key = {
  #   key_vault_resource_id  = module.avm_res_keyvault_vault[var.key_vault_key].resource_id
  #   key_name               = var.encryption_key_name
  #   user_assigned_identity = { resource_id = azurerm_user_assigned_identity.mf-core-dc-uaid[var.identity_key].id }
  # }

  # containers = {
  #   demo = {
  #     name                  = var.storage_account.container_name
  #     container_access_type = var.storage_account.container_access_type
  #     role_assignments = {
  #       contributor = {
  #         role_definition_id_or_name = "Storage Blob Data Contributor"
  #         principal_id               = azurerm_user_assigned_identity.mf-core-dc-uaid[var.identity_key].principal_id
  #       }
  #     }
  #   }
  # }

  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [var.storage_account_private_dns_zone_resource_id]
      subnet_resource_id            = module.avm-res-network-virtualnetwork.subnets[var.private_endpoint_subnet_key].resource_id
      subresource_name              = "blob"
      tags                          = local.tag_list_1
    }
  }

  network_rules = {
    private_link_access = [{
      endpoint_resource_id = "/subscriptions/${var.cfg_core_infrastructure_subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = var.cfg_tenant_id
    }]
  }

  diagnostic_settings_storage_account = local.diagnostic_settings
  diagnostic_settings_blob            = local.diagnostic_settings
  enable_telemetry                    = var.enable_telemetry
  tags                                = local.tag_list_1
}
