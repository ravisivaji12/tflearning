#### RG############
variable "cc_location" {
  type        = string
  description = "Canada Central Region"
}

variable "cc_core_resource_group_name" {
  type        = string
  description = "Resource Group Name for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}

variable "cc_storage_resource_group_name" {
  type        = string
  default     = "MF_MDI_CC_GH_STORAGE-PROD-RG"
  description = "Resource Group Name for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}

##KV#####
variable "kv_name" {
  description = "The name of the resource."
  type        = string
}
variable "sku_name" {
  description = "The SKU name for the resource."
  type        = string
}
variable "soft_delete_retention_days" {
  description = "The retention period for soft delete in days."
  type        = number
}
variable "purge_protection_enabled" {
  description = "Enable purge protection for the resource."
  type        = bool
}

variable "public_network_access_enabled" {
  description = "Enable public network access to the resource."
  type        = bool
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization for the resource."
  type        = bool
}

variable "enabled_for_deployment" {
  description = "Indicates whether the resource is enabled for deployment."
  type        = bool
}

variable "enabled_for_disk_encryption" {
  description = "Indicates whether the resource is enabled for disk encryption."
  type        = bool
}

variable "enabled_for_template_deployment" {
  description = "Indicates whether the resource is enabled for template deployment."
  type        = bool
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


variable "public_ips" {
  description = "Map of public IPs to create"
  type = map(object({
    sku               = string
    allocation_method = string
    domain_name_label = optional(string)
  }))
}

variable "cc_core_law_sku" {
  type        = string
  description = "Log Analytics Workspace SKU for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}

variable "cc_core_law_name" {
  type        = string
  description = "Log Analytics Workspace Name for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}

##############web app variable################################

variable "MF_DM_CC_CORE-appSP_Name" {
  type        = string
  description = "webapp Service plan for McCain Food Manufacturing Digital Shared Azure Components in Canada Central"
}

variable "MF-DM-CC-CORE-Webapp_Name" {
  type        = string
  description = "webapp for McCain Food Manufacturing Digital Shared Azure Components in Canada Central"
}

#############################ACR###########################
variable "cc_core_acr_name" {
  type        = string
  description = "container registry for McCain Food Manufacturing Digital Shared Azure Components in Canada Central"
}

variable "cc_core_acr_sku" {
  type        = string
  description = "Container Registry SKU for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}

##############################Container App###########################
variable "MF_MDI_CC-CAPPENV_NAME" {
  type        = string
  description = "containerapp Environment for McCain Food Manufacturing Digital Shared Azure Components in Canada Central"
}

###############################APIM###########################

variable "cc_core_apimgt_name" {
  type        = string
  description = "API Management Service Name for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}

variable "cc_core_apimgt_sku" {
  type        = string
  description = "API Management Service SKU for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"

}

variable "cc_core_apimgt_api_name" {
  type        = string
  default     = "MdiXAi-Auth-service"
  description = "Azure API Management APIs Name for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}
variable "cc_core_apimgt_logger_name" {
  type        = string
  default     = "MF_MDI_CC_CORE_PROD_APPGW-LOGGER"
  description = "Azure API Management Logger Name for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}
variable "cc_core_apimgt_nsg" {
  type        = string
  default     = "MF_MDI_CC_PROD_APIMGT-NSG"
  description = "API Management NSG Name for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}

variable "cc_core_apimgt_api_ddh" {
  type        = string
  default     = "mdixaiddh"
  description = "Azure API Management APIs Name for McCain Foods Manufacturing Digital Shared Azure Components in Canada Central"
}


variable "cc_core_app_service_plans" {
  description = "Map of App Service Plans"
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    kind                = string
    sku = object({
      tier = string
      size = string
    })
  })
}

variable "cc_core_function_apps" {
  description = "Map of Azure Function App configurations"
  type = map(object({
    name                        = string
    location                    = string
    os_type                     = string
    storage_account_name        = string
    storage_account_rg          = string
    network_name                = string
    subnet_name                 = string
    user_assigned_identity_name = string
    user_assigned_identity_rg   = string
    app_insights_name           = string
    app_insights_rg             = string
    key_vault_name              = string
    additional_app_settings     = map(string)
  }))
}

variable "cc_core_appinsights_name" {
  description = "The name of the Application Insights resource."
  type        = string
}

variable "kv_legacy_access_policies" {
  description = "Access policies for the legacy Key Vault."
  type = map(object({
    tenant_id               = string
    object_id               = string
    secret_permissions      = list(string)
    key_permissions         = list(string)
    certificate_permissions = list(string)
    storage_permissions     = list(string)
  }))
  default = {}
}

variable "kv_role_assignments" {
  description = "values for role assignments"
  type = map(object({
    role_definition_id_or_name = string
    principal_id               = string
  }))
  default = {}
}