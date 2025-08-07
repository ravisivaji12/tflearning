module "MF_MDI_CC_RG" {
  for_each = var.cc_resource_groups
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  providers = {
    azurerm = azurerm
  }
  name     = each.key #var.cc_core_resource_group_name
  location = each.value.location
  tags     = merge(local.tag_list_1, each.value.tags)
  role_assignments = {
    contributor_current_user = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Contributor"
    }
  }
  enable_telemetry = var.enable_telemetry
}

# resource "azurerm_management_lock" "rg_locks" {
#   for_each   = var.cc_resource_groups
#   name       = "${each.key}-lock"
#   scope      = module.MF_MDI_CC_RG[each.key].resource_id
#   lock_level = each.value.lock.level
#   notes      = try(each.value.lock.notes, null)
#   provider   = azurerm
# }

data "azurerm_role_assignments" "rg_roles" {
  for_each   = module.MF_MDI_CC_RG
  scope      = each.value.resource_id
  depends_on = [module.MF_MDI_CC_RG]
}

module "avm-res-network-virtualnetwork" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"
  providers = {
    azurerm = azurerm
  }
  enable_telemetry    = false
  for_each            = var.cc_vnet
  address_space       = each.value.address_space
  location            = each.value.location
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  tags                = local.tag_list_1
  subnets             = each.value.subnets
  depends_on          = [module.nsg]
}

module "nsg" {
  for_each = var.nsgs
  source   = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version  = "0.4.0"
  providers = {
    azurerm = azurerm
  }
  enable_telemetry    = false
  name                = each.key
  location            = each.value.location            #var.cc_location
  resource_group_name = each.value.resource_group_name #var.cc_core_resource_group_name
  security_rules      = each.value.security_rules
  depends_on          = [module.MF_MDI_CC_RG]
}

# module "avm-res-network-publicipaddress" {
#   source              = "Azure/avm-res-network-publicipaddress/azurerm"
#   version             = "0.2.0"
#   for_each            = var.public_ips
#   name                = each.key
#   location            = var.cc_location
#   resource_group_name = var.cc_core_resource_group_name
#   allocation_method   = each.value.allocation_method
#   sku                 = each.value.sku
#   domain_name_label   = lookup(each.value, "domain_name_label", null)
#   tags                = local.tag_list_1
#   enable_telemetry    = false
#   depends_on          = [module.MF_MDI_CC_RG]
# }

module "MF_MDI-rt" {
  for_each = local.route_tables
  source   = "Azure/avm-res-network-routetable/azurerm"
  version  = "0.4.1"
  providers = {
    azurerm = azurerm
  }
  enable_telemetry    = false
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags
  subnet_resource_ids = lookup(each.value, "subnet_resource_ids", {})
  routes              = each.value.routes
  depends_on          = [module.MF_MDI_CC_RG]
}