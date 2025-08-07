locals {
  metadata = {
    solution        = var.solution
    application     = var.application
    gl_code         = var.gl_code
    environment     = var.environment
    env_code        = local.env_codes[var.environment]
    it_owner        = var.it_owner
    onboarding_date = var.onboarding_date
    modified_date   = var.modified_date
    organization    = var.organization
    org_code        = local.org_codes[var.organization]
    business_owner  = var.business_owner
    iac_creator     = var.iac_creator
    iac_owner       = var.iac_owner
    network_posture = var.network_posture
    built_using     = var.built_using
    terraform_id    = var.terraform_id
    region          = var.region
    region_code     = local.region_codes[var.region]
  }

  tags = {
    "Application Name" = var.application
    "GL Code"          = var.gl_code
    "Environment"      = var.environment
    "IT Owner"         = var.it_owner
    "Onboard Date"     = var.onboarding_date
    "Modified Date"    = var.modified_date
    "Organization"     = var.organization
    "Business Owner"   = var.business_owner
    "Implemented by"   = var.iac_creator
    "Resource Owner"   = var.iac_owner
    "Resource Posture" = var.network_posture
    "Resource Type"    = local.env_codes[var.environment]
    "Built Using"      = var.built_using
    "AdoTfId"          = var.terraform_id
    "Solution"         = var.solution
  }
}