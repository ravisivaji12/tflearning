###    Resources

variable "name" {
  type        = string
  description = "The name of the Image Gallery."
}

variable "location" {
  type        = string
  description = "The Azure region where the Image Gallery will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the Image Gallery will be created."
}

variable "description" {
  type    = string
  default = "McCain Default Image Gallery"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the Image Gallery."
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = "An optional lock configuration for the Image Gallery."
}

variable "reader_access_AD_group_names" {
  type        = map(string)
  default     = {}
  description = "A map of Azure AD group names that will have Reader access to the Image Gallery."
}

variable "contributor_access_AD_group_names" {
  type        = map(string)
  default     = {}
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