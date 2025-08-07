####        Subscription IDs
variable "core_infrastructure_subscription_id" {
  type    = string
  default = "65763622-4bd1-45e6-82fc-2f11e3663439"
}

variable "application_subscription_id_sandbox" {
  type = string
}

variable "application_subscription_id_dev" {
  type = string
}

variable "application_subscription_id_preprod" {
  type = string
}

variable "application_subscription_id_prod" {
  type = string
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

###     Core Infra (Foundation Landing Zone) Metadata
variable "core_application" {
  type = string
}

variable "core_sub_component_image_gallery" {
  type = string
}

variable "core_sub_component_firewall" {
  type = string
}

variable "core_built_using" {
  type = string
}

variable "core_business_owner" {
  type = string
}

variable "core_gl_code" {
  type = string
}

variable "core_iac_creator" {
  type = string
}

variable "core_iac_owner" {
  type = string
}

variable "core_it_owner" {
  type = string
}

variable "core_network_posture" {
  type = string
}

variable "core_organization" {
  type = string
}

variable "core_solution" {
  type = string
}

variable "core_terraform_id" {
  type = string
}

variable "core_primary_region" {
  type = string
}

variable "core_secondary_region" {
  type = string
}

variable "core_environment" {
  type = string
}

variable "core_ce_route_table_routes" {
  type = map(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
}

variable "core_ce_hub_vnet_subnets" {
  type = map(object({
    name           = string
    address_prefix = string
  }))
}

variable "core_ce_hub_ip_cidr_ranges" {
  type = map(string)
}

variable "core_ce_hub_firewall_ip_address" {
  type = string
}

variable "core_on_prem_and_other_ip_cidr_ranges" {
  type = map(string)
}

variable "core_ce_hub_address_prefix" {
  type = string
}

variable "core_vwan_resource_group_name" {
  type = string
}

variable "core_cisco_spn_object_ids" {
  type = map(string)
}

variable "onboarding_date_image_gallery" {
  type = string
}

variable "modified_date_image_gallery" {
  type = string
}

variable "image_gallery_reader_access_AD_group_names" {
  type = map(string)
}

variable "image_gallery_contributor_access_AD_group_names" {
  type = map(string)
}

variable "image_gallery_contributor_access_service_principal_object_ids" {
  type    = map(string)
  default = {}
}

variable "image_gallery_contributor_access_user_assigned_managed_identity_object_ids_cc" {
  type    = map(string)
  default = {}
}

variable "image_gallery_contributor_access_user_assigned_managed_identity_object_ids_ce" {
  type    = map(string)
  default = {}
}

variable "ce_hub_vnet_address_spaces" {
  type = list(string)
}

variable "iaas_sysops_group_name" {
  type    = string
  default = "AADAzure_IBM_MS_Azure_P1"
}

variable "sap_root_mg_resource_id" {
  type    = string
  default = "/providers/Microsoft.Management/managementGroups/MF-SAP-MG"
}

###     Application Metadata

variable "organization" {
  type = string
}

variable "solution" {
  type = string
}

variable "environment_preprod" {
  type = string
}

variable "application" {
  type = string
}

variable "sub_component_app_gateway" {
  type = string
}

variable "sub_component_web_dispatcher" {
  type = string
}

variable "sub_component_ascs" {
  type = string
}

variable "sub_component_srm" {
  type = string
}

variable "sub_component_bw" {
  type = string
}

variable "sub_component_btp" {
  type = string
}

variable "sub_component_file_share" {
  type = string
}

variable "sub_component_deployment" {
  type = string
}

variable "sub_component_solman" {
  type = string
}

variable "sub_component_portal" {
  type = string
}

variable "sub_component_smartshift" {
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

variable "onboarding_date_tools" {
  type = string
}

variable "modified_date_tools" {
  type = string
}

variable "region" {
  type = string
}
variable "secondary_region" {
  type = string
}

###     Core Resources


###     SAP Resources

variable "storage_blob_private_dns_zone_resource_group_name" {
  type = string
}

variable "storage_blob_private_dns_zone_name" {
  type = string
}

variable "tools_vnet_address_spaces" {
  type = list(string)
}

variable "tools_vnet_address_spaces_secondary" {
  type = list(string)
}

variable "preprod_vnet_address_spaces" {
  type = list(string)
}

variable "dns_servers" {
  type = list(string)
}

variable "common_nsg_rules" {
}

variable "common_nsg_rules_secondary" {
}

variable "preprod_vnet_subnets" {
  type = map(object({
    name                   = string
    address_prefix         = string
    network_security_group = string
    route_table            = string
  }))
}

variable "hub_vnet_name" {
  type = string
}

variable "hub_vnet_id" {
  type = string
}

variable "tools_vnet_subnets" {
  type = map(object({
    name                   = string
    address_prefix         = string
    network_security_group = string
    route_table            = string
  }))
}

variable "tools_vnet_subnets_secondary" {
  type = map(object({
    name                   = string
    address_prefix         = string
    network_security_group = string
    route_table            = string
  }))
}

variable "sandbox_ad_groups" {
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

variable "sandbox_ad_groups_owner" {
  type = string
}

variable "sandbox_network_security_groups" {
}

variable "preprod_ad_groups" {
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

variable "preprod_ad_groups_owner" {
  type = string
}

variable "preprod_cloud_builder_identity_roles" {
  type = map(object({
    resource_group_name = string
    role_name           = string
  }))
}

variable "preprod_network_security_groups" {
}

variable "preprod_network_security_groups_secondary" {
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

variable "preprod_route_table_routes" {
  type = map(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
}

variable "preprod_application_security_group_names" {
  type = map(string)
}

variable "preprod_dev_application_security_group_names" {
  type = map(string)
}

variable "preprod_prod_application_security_group_names" {
  type = map(string)
}

variable "preprod_cluster_spn_object_id" {
  type = string
}

variable "cloud_builder_private_ip" {
  type = string
}

variable "cloud_builder_admin_password" {
  type      = string
  sensitive = true
}

variable "cloud_builder_admin_username" {
  type = string
}

variable "cloud_builder_computer_name" {
  type = string
}

variable "cloud_builder_image_publisher" {
  type = string
}

variable "cloud_builder_image_offer" {
  type = string
}

variable "cloud_builder_image_sku" {
  type = string
}

variable "cloud_builder_image_version" {
  type = string
}

variable "cloud_builder_sku_size" {
  type = string
}

variable "cloud_builder_overidden_name" {
  type = string
}

variable "storage_blob_private_dns_zone_resource_id" {
  type = string
}

variable "storage_file_private_dns_zone_resource_id" {
  type = string
}

variable "binaries_storage_account_private_endpoint_ip" {
  type = string
}

variable "binaries_storage_account_contributor_access_groups" {
  type = map(string)
}

variable "fileshare_storage_account_private_endpoint_ip" {
  type = string
}

variable "fileshare_storage_account_private_endpoint_dr_ip" {
  type = string
}

variable "secondary_fileshare_storage_account_private_endpoint_ip" {
  type = string
}

variable "preprod_asr_replication_storage_account_private_endpoint_ip" {
  type = string
}

variable "preprod_asr_secondary_replication_storage_account_private_endpoint_ip" {
  type = string
}

variable "preprod_key_vault_private_dns_zone_resource_id" {
  type = string
}

variable "preprod_key_vault_private_endpoint_ip" {
  type = string
}

variable "preprod_secondary_key_vault_private_endpoint_ip" {
  type = string
}

variable "preprod_backup_storage_account_private_endpoint_ip" {
  type = string
}

variable "preprod_foundational_storage_account_private_endpoint_ip" {
  type = string
}

variable "preprod_secondary_backup_storage_account_private_endpoint_ip" {
  type = string
}

variable "preprod_secondary_foundational_storage_account_private_endpoint_ip" {
  type = string
}

variable "jump_server_vm_name" {
  type = string
}

variable "jump_server_sku_size" {
  type = string
}

variable "jump_server_private_ip" {
  type = string
}

variable "jump_server_admin_username" {
  type    = string
  default = "jumpserveradmin"
}

variable "jump_server_admin_password" {
  type      = string
  sensitive = true
}

variable "jump_server_computer_name" {
  type = string
}

variable "jump_server_image_info" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "smartshift_server_vm_name" {
  type = string
}

variable "smartshift_server_sku_size" {
  type = string
}

variable "smartshift_server_private_ip" {
  type = string
}

variable "smartshift_server_admin_username" {
  type    = string
  default = "jumpserveradmin"
}

variable "smartshift_server_admin_password" {
  type      = string
  sensitive = true
}

variable "smartshift_server_computer_name" {
  type = string
}

variable "smartshift_server_image_info" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "preprod_vm_backup_policies" {
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

variable "preprod_app_registration_info" {
  type = map(object({
    component_names = map(string)
    environment     = string
    region          = string
  }))
}

variable "preprod_policy_spn_roles" {
  type = map(object({
    scope         = string
    spn_object_id = string
    role_name     = string
  }))
}

variable "preprod_policy_group_roles" {
  type = map(object({
    scope            = string
    role_name        = string
    group_identifier = string
  }))
}

# Sandbox

variable "environment_sandbox" {
  type = string
}

variable "onboarding_date_sandbox" {
  type = string
}

variable "modified_date_sandbox" {
  type = string
}

variable "sandbox_vnet_address_spaces" {
  type = list(string)
}

variable "sandbox_vnet_subnets" {
  type = map(object({
    name                   = string
    address_prefix         = string
    network_security_group = string
    route_table            = string
  }))
}

variable "sandbox_key_vault_private_endpoint_ip" {
  type = string
}

variable "sandbox_backup_storage_account_private_endpoint_ip" {
  type = string
}

variable "sandbox_foundational_storage_account_private_endpoint_ip" {
  type = string
}

variable "sandbox_binaries_storage_account_private_endpoint_ip" {
  type = string
}

variable "sandbox_fileshare_storage_account_private_endpoint_ip" {
  type = string
}

variable "sandbox_managed_identity_object_id" {
  type = string
}

variable "sandbox_vm_backup_policies" {
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
variable "sandbox_application_security_group_names" {
  type = map(string)
}

variable "sandbox_cluster_spn_object_id" {
  type = string
}

# Development

variable "environment_dev" {
  type = string
}
variable "onboarding_date_dev" {
  type = string
}
variable "modified_date_dev" {
  type = string
}
variable "dev_vnet_address_spaces" {
  type = list(string)
}
variable "dev_vnet_subnets" {
  type = map(object({
    name                   = string
    address_prefix         = string
    network_security_group = string
    route_table            = string
  }))
}

variable "dev_ad_groups" {
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

variable "dev_network_security_groups" {
}

variable "dev_ad_groups_owner" {
  type = string
}

variable "dev_key_vault_private_endpoint_ip" {
  type = string
}

variable "dev_backup_storage_account_private_endpoint_ip" {
  type = string
}

variable "dev_foundational_storage_account_private_endpoint_ip" {
  type = string
}

variable "dev_binaries_storage_account_private_endpoint_ip" {
  type = string
}

variable "dev_fileshare_storage_account_private_endpoint_ip" {
  type = string
}

variable "dev_managed_identity_object_id" {
  type = string
}

variable "dev_vm_backup_policies" {
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

variable "dev_application_security_group_names" {
  type = map(string)
}

variable "dev_cluster_spn_object_id" {
  type = string
}

variable "cluster_role_name" {
  type = string
}

variable "cluster_role_description" {
  type = string
}

variable "cluster_role_actions" {
  type = list(string)
}

variable "cluster_role_assignable_scopes" {
  type = map(string)
}

variable "cluster_role_role_definition_location_resource_id" {
  type = string
}

variable "app_registration_name" {
  type        = string
  description = "Name of the App Registration"
}

# Production

variable "environment_prod" {
  type = string
}
variable "onboarding_date_prod" {
  type = string
}
variable "modified_date_prod" {
  type = string
}
variable "prod_vnet_address_spaces" {
  type = list(string)
}
variable "prod_vnet_subnets" {
  type = map(object({
    name                   = string
    address_prefix         = string
    network_security_group = string
    route_table            = string
  }))
}

variable "prod_ad_groups" {
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

variable "prod_network_security_groups" {
}

variable "prod_ad_groups_owner" {
  type = string
}

variable "prod_key_vault_private_endpoint_ip" {
  type = string
}

variable "prod_backup_storage_account_private_endpoint_ip" {
  type = string
}

variable "prod_foundational_storage_account_private_endpoint_ip" {
  type = string
}

variable "prod_binaries_storage_account_private_endpoint_ip" {
  type = string
}

variable "prod_fileshare_storage_account_private_endpoint_ip" {
  type = string
}

variable "prod_asr_replication_storage_account_private_endpoint_ip" {
  type = string
}

variable "prod_managed_identity_object_id" {
  type = string
}

variable "prod_vm_backup_policies" {
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

variable "prod_application_security_group_names" {
  type = map(string)
}

variable "prod_cluster_spn_object_id" {
  type = string
}

variable "site_recovery_private_dns_zone_id" {
  type = string
}

variable "site_recovery_private_dns_zone_name" {
  type    = string
  default = ""
}

variable "prod_site_recovery_private_endpoint_ip_addresses" {
  type = object({
    prot2_ip_address = string
    rcm1_ip_address  = string
    tel1_ip_address  = string
    id1_ip_address   = string
    srs1_ip_address  = string
  })
}

variable "site_recovery_private_dns_zone_resource_group_name" {
  type = string
}

# Disaster Recovery
variable "environment_drr" {
  type = string
}
variable "onboarding_date_drr" {
  type = string
}
variable "modified_date_drr" {
  type = string
}
variable "drr_vnet_address_spaces" {
  type = list(string)
}
variable "drr_vnet_subnets" {
  type = map(object({
    name                   = string
    address_prefix         = string
    network_security_group = string
    route_table            = string
  }))
}

variable "drr_ad_groups" {
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

variable "drr_network_security_groups" {
}

variable "drr_ad_groups_owner" {
  type = string
}

variable "drr_key_vault_private_endpoint_ip" {
  type = string
}

variable "drr_backup_storage_account_private_endpoint_ip" {
  type = string
}

variable "drr_foundational_storage_account_private_endpoint_ip" {
  type = string
}

variable "drr_binaries_storage_account_private_endpoint_ip" {
  type = string
}

variable "drr_fileshare_storage_account_private_endpoint_ip" {
  type = string
}

variable "drr_asr_replication_storage_account_private_endpoint_ip" {
  type = string
}

variable "drr_managed_identity_object_id" {
  type = string
}

variable "drr_vm_backup_policies" {
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

variable "drr_application_security_group_names" {
  type = map(string)
}

variable "drr_cluster_spn_object_id" {
  type = string
}

variable "blob_soft_delete_retention_days_prod" {
  type    = number
  default = 60
}

variable "blob_soft_delete_retention_days_nonprod" {
  type    = number
  default = 30
}