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

variable "region_secondary" {
  type = string
}

variable "sub_component_image_gallery" {
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

variable "iaas_sysops_group_name" {
  type    = string
  default = "AADAzure_IBM_MS_Azure_P1"
}

variable "sap_root_mg_resource_id" {
  type    = string
  default = "/providers/Microsoft.Management/managementGroups/MF-SAP-MG"
}

# Canada East Hub

variable "hub_resource_group_name_ce" {
  type    = string
  default = "MF_CC_Hub-RG"
}

variable "hub_name_ce" {
  type    = string
  default = "MF_CE_Core_Vhub"
}

variable "firewall_resource_group_name_ce" {
  type    = string
  default = "MF_Core_Firewall-CE-RG"
}

variable "firewall_name_ce" {
  type    = string
  default = "MF_CE_Prod_Firewall-FW"
}

variable "firewall_vnet_name_ce" {
  type    = string
  default = "MF_CE_Core_DR_Firewall-Vnet"
}

variable "ce_hub_vnet_address_spaces" {
  type = list(string)
}

variable "ce_hub_vnet_subnets" {
  type = map(object({
    name           = string
    address_prefix = string
  }))
}

variable "ce_route_table_routes" {
  type = map(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
}

variable "sub_component_firewall" {
  type = string
}

variable "firewall_sku_tier" {
  type    = string
  default = "Standard"
}

variable "firewall_policy_name" {
  type    = string
  default = "MF_CE_Prod_FWPolicy-FWP"
}

variable "vwan_name" {
  type    = string
  default = "MF_Core_Vwan"
}

variable "ce_hub_ip_cidr_ranges" {
  type = map(string)
}

variable "cc_hub_ip_address" {
  type    = string
  default = "10.125.251.4"
}

variable "on_prem_and_other_ip_cidr_ranges" {
  type = map(string)
}

variable "hub_firewall_ip_address" {
  type = string
}

variable "ce_hub_address_prefix" {
  type = string
}

variable "vwan_resource_group_name" {
  type = string
}

variable "cisco_spn_object_ids" {
  type = map(string)
}