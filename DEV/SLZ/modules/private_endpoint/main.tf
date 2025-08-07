data "azurerm_resource_group" "rg" {
  provider = azurerm.azurerm_application_provider
  name     = var.Resource_Group_name
}

resource "azurerm_private_endpoint" "private_endpoint" {
  provider            = azurerm.azurerm_application_provider
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = var.private_endpoint_service_connection_name
    private_connection_resource_id = var.private_resource_id
    is_manual_connection           = false
    subresource_names              = var.subresource_names
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_id) > 0 ? { "1" : "1" } : {}

    content {
      name                 = substr("${var.private_dns_zone_name}-${var.private_endpoint_virtual_network_name}-dns-link", 0, 80)
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  dynamic "ip_configuration" {
    for_each = var.private_endpoints_ip_configurations
    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = ip_configuration.value.member_name
      subresource_name   = ip_configuration.value.subresource_name
    }
  }

  tags = var.tags

  depends_on = [data.azurerm_resource_group.rg]

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  provider              = azurerm.azurerm_core_infrastructure_provider
  for_each              = var.add_dns_zone_vnet_link == true ? { "1" : "1" } : {}
  name                  = substr("${var.private_dns_zone_name}-${var.private_endpoint_virtual_network_name}-link", 0, 80)
  resource_group_name   = var.private_dns_zone_resource_group_name
  private_dns_zone_name = var.private_dns_zone_name
  virtual_network_id    = var.private_endpoint_virtual_network_id
}
