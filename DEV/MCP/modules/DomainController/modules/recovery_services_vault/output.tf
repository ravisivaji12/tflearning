output "recovery_services_vault_resource" {
  value = azurerm_recovery_services_vault.vault
}

output "recovery_services_vault_id" {
  value = azurerm_recovery_services_vault.vault.id
}

output "vm_backup_policy_ids" {
  value = {
    for k, v in azurerm_backup_policy_vm.policy : k => v.id
  }
}

output "vm_backup_policy_resources" {
  value = {
    default = azurerm_backup_policy_vm.policy
  }
}