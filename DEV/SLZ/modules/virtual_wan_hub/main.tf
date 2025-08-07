data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_wan" "vwan" {
  name                = var.vwan_name
  resource_group_name = var.vwan_resource_group_name
}

data "azurerm_virtual_network" "hub_vnet" {
  name                = var.hub_firewall_virtual_network_name
  resource_group_name = var.hub_firewall_virtual_network_resource_group_name
}

data "azurerm_virtual_hub" "hub" {
  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# resource "azurerm_virtual_hub_connection" "hub_connection" {
#   name                      = var.hub_firewall_virtual_network_name
#   virtual_hub_id            = data.azurerm_virtual_hub.hub.id
#   remote_virtual_network_id = data.azurerm_virtual_network.hub_vnet.id
#   internet_security_enabled = true

#   routing {
#     associated_route_table_id                   = azurerm_virtual_hub_route_table.default.id
#     static_vnet_propagate_static_routes_enabled = false
#     propagated_route_table {
#       labels          = ["default"]
#       route_table_ids = [azurerm_virtual_hub_route_table.default.id]
#     }
#     static_vnet_route {
#       name                = "default_others_to_vwan"
#       address_prefixes    = [for k, v in var.on_prem_and_other_ip_cidr_ranges : v]
#       next_hop_ip_address = var.cc_hub_ip_address
#     }
#     dynamic "static_vnet_route" {
#       for_each = var.hub_ip_cidr_ranges
#       content {
#         name                = static_vnet_route.key
#         address_prefixes    = [static_vnet_route.value]
#         next_hop_ip_address = var.hub_firewall_ip_address
#       }
#     }
#   }
# }

# resource "azurerm_virtual_hub_route_table" "default" {
#   name           = "defaultRouteTable"
#   virtual_hub_id = data.azurerm_virtual_hub.hub.id
#   labels         = ["default"]
# }

# resource "azurerm_virtual_hub_route_table_route" "hub_default_route_table_route" {
#   for_each          = var.hub_ip_cidr_ranges
#   route_table_id    = azurerm_virtual_hub_route_table.default.id
#   name              = each.key
#   destinations_type = "CIDR"
#   destinations      = [each.value]
#   next_hop_type     = "ResourceId"
#   next_hop          = azurerm_virtual_hub_connection.hub_connection.id
# }