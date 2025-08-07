variable "vwan_name" {
  type = string
}

variable "vwan_resource_group_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "address_prefix" {
  type = string
}

variable "virtual_router_auto_scale_min_capacity" {
  type    = number
  default = 2
}

variable "hub_routing_preference" {
  type    = string
  default = "ExpressRoute"
  validation {
    condition     = contains(["ExpressRoute", "ASPath", "VpnGateway"], var.hub_routing_preference)
    error_message = "hub_routing_preference must be one of 'ExpressRoute', 'ASPath', or 'VpnGateway'."
  }
}

variable "tags" {
  type = map(string)
}

variable "hub_ip_cidr_ranges" {
  type = map(string)
}

variable "on_prem_and_other_ip_cidr_ranges" {
  type = map(string)
}

variable "hub_firewall_ip_address" {
  type = string
}

variable "cc_hub_ip_address" {
  type = string
}

variable "hub_firewall_virtual_network_name" {
  type = string
}

variable "hub_firewall_virtual_network_resource_group_name" {
  type = string
}

variable "hub_additional_routes" {
  type = map(object({
    name             = string
    destination_type = string
    destionations    = list(string)
    next_hop_type    = string
    net_hop          = string
  }))
  default = {}
}

variable "cisco_spn_object_ids" {
  type = map(string)
}