module "private_dns_zone" {
  source   = "Azure/avm-res-network-privatednszone/azurerm"
  version  = "0.3.2"
  for_each = local.private_dns_zones
  # name                = each.key
  resource_group_name   = each.value.resource_group_name
  domain_name           = each.value.domain_name
  virtual_network_links = each.value.virtual_network_links
  # a_records             = each.value.a_records
  tags = local.tag_list_1
}
