locals {
  # Organization
  organization_allowed_values = ["McCain Foods", "Day & Ross"]
  org_codes = {
    "McCain Foods" = "mf"
    "Day & Ross"   = "dr"
  }
  # Solution
  solution_allowed_values = ["AKS", "Commercial Digital", "Landing Zone", "Digital Growth", "Finance", "GenAI", "Global Data & Analytics",
  "Manufacturing Digital", "Sandbox", "SAP", "MFL", "Landing Zone"]
  # Environment
  environment_allowed_values = ["Sandbox", "Development", "Quality Assurance", "Testing", "Integration Testing", "User Acceptance", "Performance", "Pre-production", "Production", "Disaster Recovery"]
  env_codes = {
    "Sandbox"             = "sbx"
    "Development"         = "dev"
    "Quality Assurance"   = "qat"
    "Testing"             = "tst"
    "Integration Testing" = "int"
    "User Acceptance"     = "uat"
    "Performance"         = "prf"
    "Pre-production"      = "ppr"
    "Production"          = "prd"
    "Disaster Recovery"   = "drr"
  }
  # Region
  allowed_regions = ["canadacentral", "canadaeast"]
  region_codes = {
    "canadacentral" = "cc"
    "canadaeast"    = "ce"
  }
}

variable "organization" {
  type = string
  validation {
    condition     = contains(local.organization_allowed_values, var.organization)
    error_message = "The organization variable must be set to one of the following: ${join(", ", local.organization_allowed_values)}"
  }
}

variable "solution" {
  type = string
  validation {
    condition     = contains(local.solution_allowed_values, var.solution)
    error_message = "The solution variable must be set to one of the following: ${join(", ", local.solution_allowed_values)}"
  }
}

variable "environment" {
  type = string
  validation {
    condition     = contains(local.environment_allowed_values, var.environment)
    error_message = "The environment variable must be set to one of the following: ${join(", ", local.environment_allowed_values)}"
  }
}

variable "application" {
  type = string
}

variable "gl_code" {
  type = string
}

variable "it_owner" {
  type = string
  validation {
    condition     = can(regex("^.+@(mccain\\.com|dayross\\.com|mccain\\.ca)$", var.it_owner))
    error_message = "The it_owner variable must be a valid email address ending in mccain.com, mccain.ca or dayross.com"
  }
}

variable "business_owner" {
  type = string
  validation {
    condition     = can(regex("^.+@(mccain\\.com|dayross\\.com|mccain\\.ca)$", var.business_owner))
    error_message = "The business_owner variable must be a valid email address ending in mccain.com, mccain.ca or dayross.com"
  }
}

variable "iac_creator" {
  type = string
  validation {
    condition     = can(regex("^.+@(mccain\\.com|dayross\\.com|mccain\\.ca)$", var.iac_creator))
    error_message = "The iac_creator variable must be a valid email address ending in mccain.com, mccain.ca or dayross.com"
  }
}

variable "iac_owner" {
  type = string
  validation {
    condition     = can(regex("^.+@(mccain\\.com|dayross\\.com|mccain\\.ca)$", var.iac_owner))
    error_message = "The iac_owner variable must be a valid email address ending in mccain.com, mccain.ca or dayross.com"
  }
}

variable "network_posture" {
  type = string
  validation {
    condition     = contains(["Public", "Private"], var.network_posture)
    error_message = "The network_posture variable must be set to either 'Public' or 'Private'"
  }
}

variable "built_using" {
  type = string
  validation {
    condition     = contains(["Terraform_ADO", "Terraform_GitHub"], var.built_using)
    error_message = "The built_using variable must be set to either 'Terraform_ADO' or 'Terraform_GitHub'"
  }
  default = "Terraform_GitHub"
}

variable "terraform_id" {
  type = string
}

variable "onboarding_date" {
  type = string
  validation {
    condition     = can(regex("^(0[1-9]|[12][0-9]|3[01])-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-\\d{4}$", var.onboarding_date))
    error_message = "The onboarding_date variable must be a valid date in the format dd-mmm-yyyy (e.g., 01-Jan-2023)"
  }
}

variable "modified_date" {
  type = string
  validation {
    condition     = can(regex("^(0[1-9]|[12][0-9]|3[01])-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-\\d{4}$", var.modified_date))
    error_message = "The onboarding_date variable must be a valid date in the format dd-mmm-yyyy (e.g., 01-Jan-2023)"
  }
}

variable "region" {
  type = string
  validation {
    condition     = contains(local.allowed_regions, var.region)
    error_message = "The region variable must be set to one of the following: ${join(", ", local.allowed_regions)}"
  }
}