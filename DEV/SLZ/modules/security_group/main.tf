data "azuread_client_config" "current" {}

data "azuread_user" "owner" {
  provider            = azuread.azuread_mccaingroup_onmicrosoft_com
  user_principal_name = var.owner_upn
}

data "azuread_user" "member" {
  provider            = azuread.azuread_mccaingroup_onmicrosoft_com
  for_each            = var.member_upns
  user_principal_name = each.value
}

resource "azuread_group" "group" {
  provider         = azuread.azuread_mccaingroup_onmicrosoft_com
  display_name     = var.name
  security_enabled = true
  mail_enabled     = false
  description      = var.description

  owners = [
    data.azuread_client_config.current.object_id,
    data.azuread_user.owner.object_id,
  ]
}

resource "azuread_group_member" "member" {
  provider         = azuread.azuread_mccaingroup_onmicrosoft_com
  for_each         = var.member_upns
  group_object_id  = azuread_group.group.object_id
  member_object_id = data.azuread_user.member[each.key].object_id
}