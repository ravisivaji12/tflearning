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

variable "description" {
  type    = string
  default = "McCain Default Image Gallery"
}

variable "tags" {
  type = map(string)
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default = null
}

# variable "role_assignments" {
#   type = map(object({
#     role_definition_id_or_name             = string
#     principal_id                           = string
#     description                            = optional(string, null)
#     skip_service_principal_aad_check       = optional(bool, false)
#     condition                              = optional(string, null)
#     condition_version                      = optional(string, null)
#     delegated_managed_identity_resource_id = optional(string, null)
#     principal_type                         = optional(string, null)
#   }))
#   default = {}
# }

variable "reader_access_AD_group_names" {
  type    = map(string)
  default = {}
}

variable "contributor_access_AD_group_names" {
  type    = map(string)
  default = {}
}

variable "contributor_access_service_principal_object_ids" {
  type    = map(string)
  default = {}
}

variable "contributor_access_user_assigned_managed_identity_object_ids" {
  type    = map(string)
  default = {}
}