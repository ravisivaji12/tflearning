locals {
  tag_list_1 = {
    "Application Name" = "McCain DevSecOps"
    "GL Code"          = "N/A"
    "Environment"      = "sandbox"
    "IT Owner"         = "mccain-azurecontributor@mccain.ca"
    "Onboard Date"     = "12/19/2024"
    "Modified Date"    = "N/A"
    "Organization"     = "McCain Foods Limited"
    "Business Owner"   = "ravi.sivaji@mccain.ca"
    "Implemented by"   = "ravi.sivaji@mccain.ca"
    "Resource Owner"   = "ravi.sivaji@mccain.ca"
    "Resource Posture" = "Private"
    "Resource Type"    = "Terraform POC"
    "Built Using"      = "Terraform"
    "AdoTfId"          = "1982"
    "Solution"         = "Domain Controller"
  }
}

data "azurerm_client_config" "current" {}

locals {
  encoded_vm_extensions = {
    for vm_key, vm_info in var.virtual_machine_configs : vm_key => {
      for ext_key, ext in vm_info.extensions : ext_key => {
        name                       = ext.name
        publisher                  = ext.publisher
        type                       = ext.type
        type_handler_version       = ext.type_handler_version
        auto_upgrade_minor_version = lookup(ext, "auto_upgrade_minor_version", true)
        settings = ext_key == "VMAccessAgent" ? jsonencode({
          userName = var.vm_login_username # or use from a second secret
        }) : jsonencode(lookup(ext, "settings", {}))

        protected_settings = ext_key == "VMAccessAgent" ? jsonencode({
          password = random_password.admin_password.result
        }) : jsonencode(lookup(ext, "protected_settings", {}))
      }
    }
  }
}

# data "azurerm_key_vault_secret" "vm_admin_password" {
#   for_each     = var.virtual_machine_configs
#   name         = "${each.value.name}-localAdminPassword"
#   key_vault_id = module.avm_res_keyvault_vault["kv1"].resource_id
# }

locals {
  diagnostic_settings = {
    sendToLogAnalytics = {
      name                  = "sendToLogAnalytics"
      workspace_resource_id = module.log_analytics_workspace.resource.id
      metric_categories     = ["Capacity", "Transaction"]
    }
  }
}