locals {
  #==========================================================================
  # foundational_rg_roles
  #==========================================================================
  ad_group_foundational_role_assignments_list = flatten([
    for group_key, group_info in var.ad_groups : [
      for role_key, role_assignment_info in group_info.foundational_rg_roles : {
        group_key      = group_key
        group_name     = group_info.name
        assignment_key = role_key
        role_name      = role_assignment_info.role_definition_name
        final_map_key  = "${group_key}-${role_key}"
      }
    ]
  ])

  ad_group_foundational_role_assignments_map = tomap({
    for assignment in local.ad_group_foundational_role_assignments_list : assignment.final_map_key => {
      group_key      = assignment.group_key
      group_name     = assignment.group_name
      assignment_key = assignment.assignment_key
      role_name      = assignment.role_name
    }
  })
  #==========================================================================

  #==========================================================================
  # application_rg_roles
  #==========================================================================
  app_rg_list = {
    "fileshare"      = module.rg-fileshare
    "deployment"     = module.rg-deployment
    "solman"         = module.rg-solman
    "appgw"          = module.rg-app_gateway
    "web-dispatcher" = module.rg-web_dispatcher
    "ascs"           = module.rg-ascs
    "srm"            = module.rg-srm
    "bw"             = module.rg-bw
    "portal"         = module.rg-portal
    "solman-dev"     = module.rg-solman-dev
    "solman-prod"    = module.rg-solman-prod
    "smartshift"     = module.rg-smartshift
  }

  ad_group_application_rg_role_assignments_list = flatten([
    for group_key, group_info in var.ad_groups : [
      for role_key, role_assignment_info in group_info.application_rg_roles : {
        group_key      = group_key
        group_name     = group_info.name
        assignment_key = role_key
        role_name      = role_assignment_info.role_definition_name
        final_map_key  = "${group_key}-${role_key}"
      }
    ]
  ])

  ad_group_application_rg_role_assignments_map = tomap({
    for assignment in local.ad_group_application_rg_role_assignments_list : assignment.final_map_key => {
      group_key      = assignment.group_key
      group_name     = assignment.group_name
      assignment_key = assignment.assignment_key
      role_name      = assignment.role_name
    }
  })

  rg_ad_group_application_rg_role_assignments_list = flatten([
    for rg_key, rg_module in local.app_rg_list : [
      for asignment_map_key, asignment_map_info in local.ad_group_application_rg_role_assignments_map : {
        rg_assignment_key = "${rg_key}-${asignment_map_key}"
        scope             = rg_module.resource_id
        group_key         = asignment_map_info.group_key
        group_name        = asignment_map_info.group_name
        assignment_key    = asignment_map_info.assignment_key
        role_name         = asignment_map_info.role_name
      }
    ]
  ])

  rg_ad_group_application_rg_role_assignments_map = tomap({
    for assignment in local.rg_ad_group_application_rg_role_assignments_list : assignment.rg_assignment_key => {
      scope          = assignment.scope
      group_key      = assignment.group_key
      group_name     = assignment.group_name
      assignment_key = assignment.assignment_key
      role_name      = assignment.role_name
    }
  })
  #==========================================================================

  #==========================================================================
  # application_rg_custom_roles
  #==========================================================================
  ad_group_application_rg_custom_role_assignments_list = flatten([
    for group_key, group_info in var.ad_groups : [
      for role_key, role_assignment_info in group_info.application_rg_custom_roles : {
        group_key      = group_key
        group_name     = group_info.name
        assignment_key = role_key
        role_id        = role_assignment_info.role_definition_id
        final_map_key  = "${group_key}-${role_key}"
      }
    ]
  ])

  ad_group_application_rg_custom_role_assignments_map = tomap({
    for assignment in local.ad_group_application_rg_custom_role_assignments_list : assignment.final_map_key => {
      group_key      = assignment.group_key
      group_name     = assignment.group_name
      assignment_key = assignment.assignment_key
      role_id        = assignment.role_id
    }
  })

  rg_ad_group_application_rg_custom_role_assignments_list = flatten([
    for rg_key, rg_module in local.app_rg_list : [
      for asignment_map_key, asignment_map_info in local.ad_group_application_rg_custom_role_assignments_map : {
        rg_assignment_key = "${rg_key}-${asignment_map_key}"
        scope             = rg_module.resource_id
        group_key         = asignment_map_info.group_key
        group_name        = asignment_map_info.group_name
        assignment_key    = asignment_map_info.assignment_key
        role_id           = asignment_map_info.role_id
      }
    ]
  ])

  rg_ad_group_application_rg_custom_role_assignments_map = tomap({
    for assignment in local.rg_ad_group_application_rg_custom_role_assignments_list : assignment.rg_assignment_key => {
      scope          = assignment.scope
      group_key      = assignment.group_key
      group_name     = assignment.group_name
      assignment_key = assignment.assignment_key
      role_id        = assignment.role_id
    }
  })
  #==========================================================================

  #==========================================================================
  # application_rg_pim_builtin_roles
  #==========================================================================
  ad_group_app_rg_pim_builtin_role_assignments_list = flatten([
    for group_key, group_info in var.ad_groups : [
      for role_key, role_assignment_info in group_info.application_rg_pim_builtin_roles : {
        group_key      = group_key
        group_name     = group_info.name
        assignment_key = role_key
        role_name      = role_assignment_info.role_definition_name
        final_map_key  = "${group_key}-${role_key}"
      }
    ]
  ])

  ad_group_app_rg_pim_builtin_role_assignments_map = tomap({
    for assignment in local.ad_group_app_rg_pim_builtin_role_assignments_list : assignment.final_map_key => {
      group_key      = assignment.group_key
      group_name     = assignment.group_name
      assignment_key = assignment.assignment_key
      role_name      = assignment.role_name
    }
  })

  rg_ad_group_app_rg_pim_builtin_role_assignments_list = flatten([
    for rg_key, rg_module in local.app_rg_list : [
      for asignment_map_key, asignment_map_info in local.ad_group_app_rg_pim_builtin_role_assignments_map : {
        rg_assignment_key = "${rg_key}-${asignment_map_key}"
        scope             = rg_module.resource_id
        group_key         = asignment_map_info.group_key
        group_name        = asignment_map_info.group_name
        assignment_key    = asignment_map_info.assignment_key
        role_name         = asignment_map_info.role_name
      }
    ]
  ])

  rg_ad_group_app_rg_pim_builtin_role_assignments_map = tomap({
    for assignment in local.rg_ad_group_app_rg_pim_builtin_role_assignments_list : assignment.rg_assignment_key => {
      scope          = assignment.scope
      group_key      = assignment.group_key
      group_name     = assignment.group_name
      assignment_key = assignment.assignment_key
      role_name      = assignment.role_name
    }
  })
  #==========================================================================

  #==========================================================================
  # application_rg_pim_custom_roles
  #==========================================================================
  ad_group_app_rg_pim_custom_role_assignments_list = flatten([
    for group_key, group_info in var.ad_groups : [
      for role_key, role_assignment_info in group_info.application_rg_pim_custom_roles : {
        group_key      = group_key
        group_name     = group_info.name
        assignment_key = role_key
        role_id        = role_assignment_info.role_definition_id
        final_map_key  = "${group_key}-${role_key}"
      }
    ]
  ])

  ad_group_app_rg_pim_custom_role_assignments_map = tomap({
    for assignment in local.ad_group_app_rg_pim_custom_role_assignments_list : assignment.final_map_key => {
      group_key      = assignment.group_key
      group_name     = assignment.group_name
      assignment_key = assignment.assignment_key
      role_id        = assignment.role_id
    }
  })

  rg_ad_group_app_rg_pim_custom_role_assignments_list = flatten([
    for rg_key, rg_module in local.app_rg_list : [
      for asignment_map_key, asignment_map_info in local.ad_group_app_rg_pim_custom_role_assignments_map : {
        rg_assignment_key = "${rg_key}-${asignment_map_key}"
        scope             = rg_module.resource_id
        group_key         = asignment_map_info.group_key
        group_name        = asignment_map_info.group_name
        assignment_key    = asignment_map_info.assignment_key
        role_id           = asignment_map_info.role_id
      }
    ]
  ])

  rg_ad_group_app_rg_pim_custom_role_assignments_map = tomap({
    for assignment in local.rg_ad_group_app_rg_pim_custom_role_assignments_list : assignment.rg_assignment_key => {
      scope          = assignment.scope
      group_key      = assignment.group_key
      group_name     = assignment.group_name
      assignment_key = assignment.assignment_key
      role_id        = assignment.role_id
    }
  })
  #==========================================================================
}