variable "cfg_core_infrastructure_subscription_id" {
  type    = string
  default = "65763622-4bd1-45e6-82fc-2f11e3663439"
}

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

variable "application_name_domain_controllers" {
  type    = string
  default = "core"
}

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

variable "cfg_tenant_id" {
  type    = string
  default = "59fa7797-abec-4505-81e6-8ce092642190"
}

variable "domain_controller_component_name" {
  type    = string
  default = "domaincontroller"
}

variable "domain_controller_vnet_config" {
  type = object({
    vnet_address_space = string,
    subnets = map(object({
      subnet_identifier = string,
      address_space     = string
    }))
  })
}

variable "domain_controller_private_ip_1" {
  type = string
}

variable "domain_controller_private_ip_2" {
  type = string
}

variable "domain_controller_password" {
  type = string
}

variable "private_endpoint_subnet_key" {
  type        = string
  description = "Key for the private endpoint subnet in the domain controller VNet"
  default     = "private-endpoint"
}

variable "NIC_subnet_key" {
  type        = string
  description = "Key for the NIC subnet in the domain controller VNet"
  default     = "app"
}

variable "identity_key" {
  type        = string
  description = "Key for the user assigned identity to be used for CMK encryption"
  default     = "mf-core-dc-uaid"
}

variable "key_vault_key" {
  type    = string
  default = "kv1"
}

variable "disk_encryption_set_config_key" {
  type    = string
  default = "encryption-key"
}

variable "default_vm_username" {
  type        = string
  description = "Default username for the virtual machines"
  default     = "mccaindcuser"
}

variable "default_domain_controller_hostname" {
  type        = string
  description = "Default hostname for the domain controller"
  default     = "nmfazrdc"
}

variable "domain_controller_suffix_1" {
  type        = string
  description = "Suffix for the first domain controller"
}

variable "domain_controller_suffix_2" {
  type        = string
  description = "Suffix for the second domain controller"
}

variable "key_vault_private_dns_zone_resource_id" {
  type        = string
  description = "Resource ID of the Key Vault private DNS zone"
  default     = "/subscriptions/65763622-4bd1-45e6-82fc-2f11e3663439/resourceGroups/mf_private_endpoint_prod-rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
}

variable "storage_account_private_dns_zone_resource_id" {
  type        = string
  description = "Resource ID of the Storage Account private DNS zone"
  default     = "/subscriptions/65763622-4bd1-45e6-82fc-2f11e3663439/resourceGroups/mf_private_endpoint_prod-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
}

variable "encryption_key_name" {
  type        = string
  description = "Name of the encryption key to be used for disk encryption"
  default     = "disk-key"
}

variable "hub_vnet_name" {
  type        = string
  description = "Name of the hub virtual network"
}

variable "hub_vnet_id" {
  type        = string
  description = "Resource ID of the hub virtual network"
}

variable "reader_access_AD_group_names" {
  type        = map(string)
  default     = {}
  description = "A map of Azure AD group names that will have Reader access to the Image Gallery."
}

variable "contributor_access_AD_group_names" {
  type = map(string)
  default = {
    "SAP-Infra" : "MF-SAP-Infra-PPR-AAD-GRP"
  }
  description = "A map of Azure AD group names that will have Contributor access to the Image Gallery."
}

variable "contributor_access_service_principal_object_ids" {
  type        = map(string)
  default     = {}
  description = "A map of Azure AD service principal object IDs that will have Contributor access to the Image Gallery."
}

variable "contributor_access_user_assigned_managed_identity_object_ids" {
  type        = map(string)
  default     = {}
  description = "A map of Azure AD user-assigned managed identity object IDs that will have Contributor access to the Image Gallery."
}

variable "image_gallery_name" {
  type        = string
  description = "The name of the Image Gallery."
  default     = ""
}

variable "image_gallery_resource_group_name" {
  type        = string
  description = "The name of the resource group where the Image Gallery will be created."
  default     = ""
}

variable "enable_dc_vnet_peering" {
  type        = bool
  default     = true
  description = "Flag to enable peering between the domain controller VNet and the hub VNet"
}