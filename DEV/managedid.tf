resource "azurerm_user_assigned_identity" "MF_MDI_CC_CORE_APP_ACCESS-USER-IDENTITY" {
  resource_group_name = var.cc_core_resource_group_name
  location            = var.cc_location
  name                = "MF_CC_CORE_PROD_APP_ACCESS-USER-IDENTITY"
  lifecycle {
    # prevent_destroy = true
  }
  tags = local.tag_list_1
}