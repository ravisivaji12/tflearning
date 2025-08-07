module "avm-res-network-virtualnetwork" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.8.1"
  for_each            = var.cc_vnet
  address_space       = each.value.address_space
  location            = each.value.location
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  tags                = local.tag_list_1
  subnets             = each.value.subnets
}


module "nsg" {
  for_each            = var.nsgs
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.4.0"
  name                = each.key
  location            = var.cc_location
  resource_group_name = var.cc_core_resource_group_name
  security_rules      = each.value.security_rules
}

module "avm-res-network-publicipaddress" {
  source              = "Azure/avm-res-network-publicipaddress/azurerm"
  version             = "0.2.0"
  for_each            = var.public_ips
  name                = each.key
  location            = var.cc_location
  resource_group_name = var.cc_core_resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  domain_name_label   = lookup(each.value, "domain_name_label", null)
  tags                = local.tag_list_1
}

