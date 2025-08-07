variable "metadata" {
  type = object({
    region          = string
    region_code     = string
    solution        = string
    application     = string
    gl_code         = string
    environment     = string
    env_code        = string
    it_owner        = string
    onboarding_date = string
    modified_date   = string
    organization    = string
    org_code        = string
    business_owner  = string
    iac_creator     = string
    iac_owner       = string
    network_posture = string
    built_using     = string
    terraform_id    = string
  })
}

variable "sub_component" {
  type        = string
  description = "Sub component of the application"
  default     = ""
}

variable "suffix" {
  type = string
  validation {
    condition     = var.suffix == "" || can(regex("^\\d{1,3}$", var.suffix))
    error_message = "The suffix variable must either be a blank string or a number containing 1-3 digits."
  }
  default = ""
}

variable "is_foundational_resource" {
  type        = bool
  default     = false
  description = "Set to true if the resource is foundational, e.g. the foundational resource group"
}