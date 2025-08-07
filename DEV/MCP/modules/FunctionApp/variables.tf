variable "blob_soft_delete_retention_days" {
  type    = number
  default = 7
}

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

variable "environment_dev" {
  type = string
}

variable "application_name_dev" {
  type = string
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

variable "cfg_aad_client_id" {
  type    = string
  default = "bea87b4a-0c2f-4ff3-9fd6-c8d974405587"
}

variable "cfg_aad_client_secret" {
  type = string
}

variable "additional_app_settings" {
  type    = map(string)
  default = {}
}