data "azuread_group" "reader_groups" {
  provider     = azuread.azuread_mccaingroup_onmicrosoft_com
  for_each     = var.reader_access_AD_group_names
  display_name = each.value
}

data "azuread_group" "contributor_groups" {
  provider     = azuread.azuread_mccaingroup_onmicrosoft_com
  for_each     = var.contributor_access_AD_group_names
  display_name = each.value
}

module "image_gallery" {
  providers = {
    azurerm = azurerm
    azuread = azuread.azuread_mccaingroup_onmicrosoft_com
  }
  source              = "Azure/avm-res-compute-gallery/azurerm"
  version             = "0.2.0"
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  description         = var.description
  lock                = var.lock
  role_assignments = merge(
    { for k, group_name in var.reader_access_AD_group_names : "Reader-${group_name}" => {
      role_definition_id_or_name = "Reader"
      principal_id               = data.azuread_group.reader_groups[k].object_id
      principal_type             = "Group"
      }
    },
    { for k, group_name in var.contributor_access_AD_group_names : "Contributor-${group_name}" => {
      role_definition_id_or_name = "Contributor"
      principal_id               = data.azuread_group.contributor_groups[k].object_id
      principal_type             = "Group"
      }
    },
    { for k, spn_object_id in var.contributor_access_service_principal_object_ids : "Contributor-${spn_object_id}" => {
      role_definition_id_or_name = "Contributor"
      principal_id               = spn_object_id
      principal_type             = "ServicePrincipal"
      }
    },
    { for k, uami_object_id in var.contributor_access_user_assigned_managed_identity_object_ids : "Contributor-${uami_object_id}" => {
      role_definition_id_or_name = "Contributor"
      principal_id               = uami_object_id
      principal_type             = "ServicePrincipal"
      }
    }
  )
  tags             = var.tags
  enable_telemetry = false
}