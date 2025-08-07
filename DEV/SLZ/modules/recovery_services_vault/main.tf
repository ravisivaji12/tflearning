resource "azurerm_recovery_services_vault" "vault" {
  provider                      = azurerm.azurerm_application_provider
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = var.tags
  sku                           = "Standard"
  public_network_access_enabled = length(var.site_recovery_private_dns_zone_id) > 0 ? false : true
  immutability                  = "Locked"
  storage_mode_type             = var.storage_mode_type
  cross_region_restore_enabled  = var.cross_region_restore_enabled

  identity {
    type = "SystemAssigned"
  }

  soft_delete_enabled = true
}

data "azurerm_resource_group" "rg" {
  provider = azurerm.azurerm_application_provider
  name     = var.resource_group_name
}

resource "azurerm_backup_policy_vm" "policy" {
  provider            = azurerm.azurerm_application_provider
  for_each            = var.vm_backup_policies
  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = each.value.timezone

  backup {
    frequency = each.value.frequency
    time      = each.value.time
  }

  retention_daily {
    count = each.value.retention_daily.count
  }

  dynamic "retention_weekly" {
    for_each = each.value.retention_weekly.count > 0 ? [1] : []
    content {
      count    = each.value.retention_weekly.count
      weekdays = each.value.retention_weekly.weekdays
    }
  }

  dynamic "retention_monthly" {
    for_each = each.value.retention_monthly.count > 0 ? [1] : []
    content {
      count    = each.value.retention_monthly.count
      weekdays = each.value.retention_monthly.weekdays
      weeks    = each.value.retention_monthly.weeks
    }
  }

  dynamic "retention_yearly" {
    for_each = each.value.retention_yearly.count > 0 ? [1] : []
    content {
      count    = each.value.retention_yearly.count
      weekdays = each.value.retention_yearly.weekdays
      weeks    = each.value.retention_yearly.weeks
      months   = each.value.retention_yearly.months
    }
  }
}

module "private_endpoint_site_recovery" {
  for_each = length(var.site_recovery_private_dns_zone_id) > 0 ? { "1" : "1" } : {}
  providers = {
    azurerm.azurerm_application_provider         = azurerm.azurerm_application_provider
    azurerm.azurerm_core_infrastructure_provider = azurerm.azurerm_core_infrastructure_provider
    azuread.azuread_mccaingroup_onmicrosoft_com  = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source = "../../modules/private_endpoint"

  location                                 = var.location
  Resource_Group_name                      = data.azurerm_resource_group.rg.name
  tags                                     = var.tags
  private_endpoint_name                    = "${var.name}-siterecovery-pe"
  private_resource_id                      = azurerm_recovery_services_vault.vault.id
  private_endpoint_subnet_id               = var.private_endpoint_subnet_id
  private_endpoint_virtual_network_name    = var.private_endpoint_vnet_name
  private_endpoint_service_connection_name = var.private_endpoint_vnet_name
  subresource_names                        = ["AzureSiteRecovery"]
  private_endpoints_ip_configurations      = {}
  private_dns_zone_id                      = var.site_recovery_private_dns_zone_id
  private_dns_zone_name                    = var.site_recovery_private_dns_zone_name
  # private_endpoints_ip_configurations = {
  #   prot2 : {
  #     "name" : "${var.name}-siterecovery-pe-prot2-ipconfig",
  #     "private_ip_address" : var.private_endpoint_ip_addresses.prot2_ip_address,
  #     "subresource_name" : "AzureSiteRecovery",
  #     "member_name" : "SiteRecovery-prot2"
  #   }
  #   rcm1 : {
  #     "name" : "${var.name}-siterecovery-pe-rcm1-ipconfig",
  #     "private_ip_address" : var.private_endpoint_ip_addresses.rcm1_ip_address,
  #     "subresource_name" : "AzureSiteRecovery",
  #     "member_name" : "SiteRecovery-rcm1"
  #   }
  #   tel1 : {
  #     "name" : "${var.name}-siterecovery-pe-tel1-ipconfig",
  #     "private_ip_address" : var.private_endpoint_ip_addresses.tel1_ip_address,
  #     "subresource_name" : "AzureSiteRecovery",
  #     "member_name" : "SiteRecovery-tel1"
  #   }
  #   id1 : {
  #     "name" : "${var.name}-siterecovery-pe-id1-ipconfig",
  #     "private_ip_address" : var.private_endpoint_ip_addresses.id1_ip_address,
  #     "subresource_name" : "AzureSiteRecovery",
  #     "member_name" : "SiteRecovery-id1"
  #   }
  #   srs1 : {
  #     "name" : "${var.name}-siterecovery-pe-srs1-ipconfig",
  #     "private_ip_address" : var.private_endpoint_ip_addresses.srs1_ip_address,
  #     "subresource_name" : "AzureSiteRecovery",
  #     "member_name" : "SiteRecovery-srs1"
  #   }
  # }
  private_dns_zone_resource_group_name = var.site_recovery_private_dns_zone_resource_group_name
  private_endpoint_virtual_network_id  = var.private_endpoint_vnet_resource_id
  add_dns_zone_vnet_link               = var.add_site_recovery_dns_zone_vnet_link
}

# resource "azurerm_private_endpoint" "private_endpoint" {
#   provider            = azurerm.azurerm_application_provider
#   name                = var.private_endpoint_name
#   location            = var.location
#   resource_group_name = data.resource_group_name
#   subnet_id           = var.private_endpoint_subnet_id

#   private_service_connection {
#     name                           = var.private_endpoint_service_connection_name
#     private_connection_resource_id = azurerm_recovery_services_vault.vault.id
#     is_manual_connection           = false
#     subresource_names              = ["AzureBackup"]
#   }

#   private_dns_zone_group {
#     name                 = substr("${var.private_dns_zone_name}-${var.private_endpoint_virtual_network_name}-dns-link", 0, 80)
#     private_dns_zone_ids = [var.private_dns_zone_id]
#   }

#   dynamic "ip_configuration" {
#     for_each = var.private_endpoints_ip_configurations
#     content {
#       name               = ip_configuration.value.name
#       private_ip_address = ip_configuration.value.private_ip_address
#       member_name        = ip_configuration.value.member_name
#       subresource_name   = ip_configuration.value.subresource_name
#     }
#   }

#   tags = var.tags

#   # lifecycle {
#   #   prevent_destroy = true
#   # }
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
#   provider              = azurerm.MF-Core-Infrastructure-Prod-Subscription
#   for_each              = var.add_dns_zone_vnet_link == true ? { "1" : "1" } : {}
#   name                  = substr("${var.private_dns_zone_name}-${var.private_endpoint_virtual_network_name}-link", 0, 80)
#   resource_group_name   = var.private_dns_zone_resource_group_name
#   private_dns_zone_name = var.private_dns_zone_name
#   virtual_network_id    = var.private_endpoint_virtual_network_id
# }