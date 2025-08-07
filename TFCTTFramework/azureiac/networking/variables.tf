variable "cc_location" {
  type        = string
  description = "Canada Central Region"
}

variable "cc_core_resource_group_name" {
  type        = string
  description = "Resource Group Name for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}

variable "enable_telemetry" {
  type        = bool
  description = "Flag for enabling telemetry for the AVM Modules"
  default     = false
}

variable "cc_resource_groups" {
  type = map(object({
    location = string
    tags     = optional(map(string), {})
    lock = optional(object({
      level = string
      notes = optional(string)
    }), null)
  }))
  description = "Resource Groups for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central Region with Tags"
}

variable "cc_vnet" {
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    address_space       = list(string)
    subnets = map(object({
      name                              = string
      address_prefixes                  = list(string)
      service_endpoints                 = list(string)
      default_outbound_access_enabled   = bool
      private_endpoint_network_policies = string
      delegation = list(object({
        name = string
        service_delegation = object({
          name = string
        actions = list(string) })
      }))
    }))
  }))
  description = "Map of virtual networks"
}

variable "nsgs" {
  description = "Map of NSGs to create"
  type = map(object({
    location            = string
    resource_group_name = string
    security_rules = map(object({
      name                         = string
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_address_prefix        = string
      source_port_range            = string
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
    }))
  }))
}
# variable "public_ips" {
#   description = "Map of public IPs to create"
#   type = map(object({
#     sku               = string
#     allocation_method = string
#     domain_name_label = optional(string)
#   }))
# }