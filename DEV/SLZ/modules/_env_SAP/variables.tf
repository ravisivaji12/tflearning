####        Subscription IDs
variable "core_infrastructure_subscription_id" {
  type    = string
  default = "65763622-4bd1-45e6-82fc-2f11e3663439"
}

variable "MF_tenant_id" {
  type    = string
  default = "59fa7797-abec-4505-81e6-8ce092642190"
}

###            Terraform Client ID and Secrets

variable "MF_Terraform_CS" {
  type    = string
  default = ""
}

variable "MF_terraform_CI" {
  type    = string
  default = "b58ca4ea-c798-4fdf-a9a4-16a878e4fb54"

}

variable "MF_CI_AAD_CS" {
  type    = string
  default = ""
}

variable "MF_AAD_client_id" {
  type    = string
  default = "bea87b4a-0c2f-4ff3-9fd6-c8d974405587"
}

###     Platform execution
variable "_ADOTfId" {
  type    = string
  default = "NNNN"
}

###     Metadata

variable "organization" {
  type = string
}

variable "solution" {
  type = string
}

variable "environment" {
  type = string
}

variable "application" {
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

variable "region" {
  type = string
}

variable "sub_component_srm" {
  type = string
}

variable "sub_component_bw" {
  type = string
}

variable "sub_component_solman" {
  type = string
}

variable "sub_component_portal" {
  type = string
}

###     Resources

variable "vnet_address_spaces" {
  type = list(string)
}

variable "dns_servers" {
  type = list(string)
}

variable "common_nsg_rules" {
}

variable "common_nsg_rules_secondary" {
}

variable "hub_vnet_name" {
  type = string
}

variable "hub_vnet_id" {
  type = string
}

variable "storage_blob_private_dns_zone_resource_group_name" {
  type = string
}

variable "vnet_subnets" {
  type = map(object({
    name                   = string
    address_prefix         = string
    network_security_group = string
    route_table            = string
  }))
}

variable "ad_groups" {
  type = map(object({
    name        = string
    description = string
    member_upns = map(string)
    foundational_rg_roles = map(object({
      role_definition_name = string
    }))
    application_rg_roles = map(object({
      role_definition_name = string
    }))
    application_rg_custom_roles = map(object({
      role_definition_id = string
    }))
    application_rg_pim_builtin_roles = map(object({
      role_definition_name = string
    }))
    application_rg_pim_custom_roles = map(object({
      role_definition_id = string
    }))
  }))
}

variable "ad_groups_owner" {
  type = string
  validation {
    condition     = can(regex("^(adm|ADM)", var.ad_groups_owner))
    error_message = "Please provice the admin account of the owner, and not normal account"
  }
}

variable "managed_identity_object_id" {
  type = string
}

variable "network_security_groups" {
}

variable "route_tables" {
  type = map(object({
    name = string
    routes = map(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    }))
  }))
}

variable "route_table_routes" {
  type = map(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
}

variable "storage_blob_private_dns_zone_resource_id" {
  type = string
}

variable "storage_blob_private_dns_zone_name" {
  type = string
}

variable "key_vault_private_dns_zone_resource_id" {
  type = string
}

variable "key_vault_private_endpoint_ip" {
  type = string
}

variable "backup_storage_account_private_endpoint_ip" {
  type = string
}

variable "foundational_storage_account_private_endpoint_ip" {
  type = string
}

variable "asr_replication_storage_account_private_endpoint_ip" {
  type = string
}

variable "recovery_services_vault_storage_mode_type" {
  type    = string
  default = "ZoneRedundant"
}

variable "recovery_services_vault_cross_region_restore_enabled" {
  type    = bool
  default = false
}

variable "monitoring_tools_vnet_name" {
  type = string
}

variable "monitoring_tools_vnet_id" {
  type = string
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

variable "sap_binaries_storage_account_name" {
  type = string
}

variable "sap_binaries_storage_account_id" {
  type = string
}

variable "fileshare_storage_account_name" {
  type = string
}

variable "fileshare_storage_account_id" {
  type = string
}

variable "sap_binaries_storage_private_endpoint_ip" {
  type = string
}

variable "fileshare_storage_private_endpoint_ip" {
  type = string
}

variable "application_security_group_names" {
  type = map(string)
}

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


variable "app_registration_name" {
  type        = string
  description = "Name of the App Registration"
}


# variable "application_id" {
#   type        = string
#   description = "Application ID from the App Registration"
# }

variable "cluster_spn_object_id" {
  type = string
}

variable "cluster_role_definition_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "site_recovery_private_dns_zone_id" {
  type    = string
  default = ""
}

variable "site_recovery_private_dns_zone_name" {
  type    = string
  default = ""
}

variable "site_recovery_private_endpoint_ip_addresses" {
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

variable "production_asr_vault_resource_id" {
  type    = string
  default = ""
}

variable "blob_soft_delete_retention_days" {
  type    = number
  default = 7
}