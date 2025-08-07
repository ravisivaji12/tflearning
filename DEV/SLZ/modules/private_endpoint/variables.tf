###     Common variables

variable "location" {
  type = string
}

variable "Resource_Group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

###    Resources

variable "private_endpoint_name" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}


variable "private_endpoint_service_connection_name" {
  type = string
}

variable "private_resource_id" {
  type = string
}

variable "subresource_names" {
  type = list(string)
}

variable "private_dns_zone_id" {
  type    = string
  default = ""
}

variable "private_dns_zone_name" {
  type    = string
  default = ""
}

variable "private_dns_zone_resource_group_name" {
  type    = string
  default = ""
}

variable "private_endpoint_virtual_network_name" {
  type = string
}

variable "private_endpoint_virtual_network_id" {
  type = string
}

variable "private_endpoints_ip_configurations" {
  type = map(object({
    name               = string
    private_ip_address = string
    subresource_name   = string
    member_name        = string
  }))
}

variable "add_dns_zone_vnet_link" {
  type    = bool
  default = true
}