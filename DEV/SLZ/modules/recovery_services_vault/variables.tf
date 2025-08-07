###    Resources

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "storage_mode_type" {
  type    = string
  default = "GeoRedundant"
}

variable "cross_region_restore_enabled" {
  type    = bool
  default = false
}

variable "vm_backup_policies" {
  type = map(object({
    name      = string
    timezone  = string
    frequency = string
    time      = string
    retention_daily = object({
      count = number
    })
    retention_weekly = object({
      count    = number
      weekdays = list(string)
    })
    retention_monthly = object({
      count    = number,
      weekdays = list(string)
      weeks    = list(string)
    })
    retention_yearly = object({
      count    = number
      weekdays = list(string)
      weeks    = list(string)
      months   = list(string)
    })
  }))
}

variable "site_recovery_private_dns_zone_id" {
  type    = string
  default = ""
}

variable "site_recovery_private_dns_zone_name" {
  type    = string
  default = ""
}

variable "private_endpoint_subnet_id" {
  type    = string
  default = ""
}

variable "private_endpoint_vnet_name" {
  type    = string
  default = ""
}

variable "private_endpoint_vnet_resource_id" {
  type    = string
  default = ""
}

variable "add_site_recovery_dns_zone_vnet_link" {
  type    = bool
  default = true
}

variable "private_endpoint_ip_addresses" {
  type = object({
    prot2_ip_address = string
    rcm1_ip_address  = string
    tel1_ip_address  = string
    id1_ip_address   = string
    srs1_ip_address  = string
  })
  default = null
}

variable "site_recovery_private_dns_zone_resource_group_name" {
  type    = string
  default = ""
}

# variable "private_endpoint_name" {
#   type = string
# }

# variable "private_endpoint_subnet_id" {
#   type = string
# }

# variable "private_endpoint_service_connection_name" {
#   type = string
# }

# variable "private_dns_zone_name" {
#   type = string
# }

# variable "private_endpoint_virtual_network_name" {
#   type = string
# }

# variable "private_dns_zone_id" {
#   type = string
# }

# variable "private_endpoints_ip_configurations" {
#   type = list(object({
#     name               = string
#     private_ip_address = string
#     member_name        = string
#     subresource_name   = string
#   }))
# }

# variable "add_dns_zone_vnet_link" {
#   type = bool
#   default = true
# }