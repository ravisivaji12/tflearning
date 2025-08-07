###     Metadata

variable "organization" {
  type = string
}

variable "lob_or_platform" {
  type = string
}

variable "environment" {
  type    = string
  default = "Production"
}

# variable "environment_sandbox" {
#   type = string
# }

# variable "environment_nonprod" {
#   type = string
# }

variable "environment_dev" {
  type = string
}

variable "application_name_dev" {
  type = string
}

# variable "application_name" {
#   type = string
# }

variable "region" {
  type = string
}

variable "gl_code" {
  type = string
}

variable "it_owner" {
  type = string
}

variable "business_owner" {
  type = string
}

variable "iac_creator" {
  type = string
}

variable "iac_owner" {
  type = string
}

variable "network_posture" {
  type = string
}

variable "built_using" {
  type = string
}

variable "terraform_id" {
  type = string
}

variable "onboarding_date" {
  type = string
}

variable "modified_date" {
  type = string
}

variable "cfg_core_infrastructure_subscription_id" {
  type    = string
  default = "65763622-4bd1-45e6-82fc-2f11e3663439"
}

variable "cfg_aad_client_id" {
  type    = string
  default = "bea87b4a-0c2f-4ff3-9fd6-c8d974405587"
}

variable "cfg_aad_client_secret" {
  type = string
}

variable "cfg_tenant_id" {
  type    = string
  default = "59fa7797-abec-4505-81e6-8ce092642190"
}

variable "blob_soft_delete_retention_days" {
  type    = number
  default = 7
}

variable "additional_finops_parking_function_app_settings" {
  type    = map(string)
  default = {}
}

variable "platform_infrastructure_regional_footprint" {
  type = map(object({
    domain_controller_vnet_config = object({
      vnet_address_space = string,
      subnets = map(object({
        subnet_identifier = string,
        address_space     = string
      }))
    })
    domain_controller_private_ip_1    = string
    domain_controller_private_ip_2    = string
    domain_controller_password        = string
    domain_controller_suffix_1        = string
    domain_controller_suffix_2        = string
    hub_vnet_name                     = string
    hub_vnet_id                       = string
    image_gallery_resource_group_name = string
    image_gallery_name                = string
    enable_dc_vnet_peering            = optional(bool, true)
  }))
  description = "Map of regional footprints for platform infrastructure. This allows setting up the infrastructure in a new region quickly without requiring addition of a lot of code or config"
}

variable "defender_plans" {
  type = map(object(
    {
      resource_type = string
      sub_plan      = optional(string, null)
      extensions = optional(map(object({
        name                  = string
        additional_properties = optional(map(string), {})
      })), {})
    }
  ))
  description = "Map of Defender plans"
  nullable    = false
}