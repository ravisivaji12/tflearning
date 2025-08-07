module "MF_MDI-rt" {
  for_each            = local.route_tables
  source              = "Azure/avm-res-network-routetable/azurerm"
  version             = "0.4.1"
  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags
  subnet_resource_ids = lookup(each.value, "subnet_resource_ids", {})
  routes              = each.value.routes
}