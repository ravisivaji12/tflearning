<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm.azurerm_application_provider"></a> [azurerm.azurerm\_application\_provider](#provider\_azurerm.azurerm\_application\_provider) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_private_endpoint_site_recovery"></a> [private\_endpoint\_site\_recovery](#module\_private\_endpoint\_site\_recovery) | ../../modules/private_endpoint | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_backup_policy_vm.policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_vm) | resource |
| [azurerm_recovery_services_vault.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_site_recovery_dns_zone_vnet_link"></a> [add\_site\_recovery\_dns\_zone\_vnet\_link](#input\_add\_site\_recovery\_dns\_zone\_vnet\_link) | n/a | `bool` | `true` | no |
| <a name="input_cross_region_restore_enabled"></a> [cross\_region\_restore\_enabled](#input\_cross\_region\_restore\_enabled) | n/a | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_private_endpoint_ip_addresses"></a> [private\_endpoint\_ip\_addresses](#input\_private\_endpoint\_ip\_addresses) | n/a | <pre>object({<br>    prot2_ip_address = string<br>    rcm1_ip_address  = string<br>    tel1_ip_address  = string<br>    id1_ip_address   = string<br>    srs1_ip_address  = string<br>  })</pre> | `null` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | n/a | `string` | `""` | no |
| <a name="input_private_endpoint_vnet_name"></a> [private\_endpoint\_vnet\_name](#input\_private\_endpoint\_vnet\_name) | n/a | `string` | `""` | no |
| <a name="input_private_endpoint_vnet_resource_id"></a> [private\_endpoint\_vnet\_resource\_id](#input\_private\_endpoint\_vnet\_resource\_id) | n/a | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_site_recovery_private_dns_zone_id"></a> [site\_recovery\_private\_dns\_zone\_id](#input\_site\_recovery\_private\_dns\_zone\_id) | n/a | `string` | `""` | no |
| <a name="input_site_recovery_private_dns_zone_name"></a> [site\_recovery\_private\_dns\_zone\_name](#input\_site\_recovery\_private\_dns\_zone\_name) | n/a | `string` | `""` | no |
| <a name="input_site_recovery_private_dns_zone_resource_group_name"></a> [site\_recovery\_private\_dns\_zone\_resource\_group\_name](#input\_site\_recovery\_private\_dns\_zone\_resource\_group\_name) | n/a | `string` | `""` | no |
| <a name="input_storage_mode_type"></a> [storage\_mode\_type](#input\_storage\_mode\_type) | n/a | `string` | `"GeoRedundant"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | n/a | yes |
| <a name="input_vm_backup_policies"></a> [vm\_backup\_policies](#input\_vm\_backup\_policies) | n/a | <pre>map(object({<br>    name      = string<br>    timezone  = string<br>    frequency = string<br>    time      = string<br>    retention_daily = object({<br>      count = number<br>    })<br>    retention_weekly = object({<br>      count    = number<br>      weekdays = list(string)<br>    })<br>    retention_monthly = object({<br>      count    = number,<br>      weekdays = list(string)<br>      weeks    = list(string)<br>    })<br>    retention_yearly = object({<br>      count    = number<br>      weekdays = list(string)<br>      weeks    = list(string)<br>      months   = list(string)<br>    })<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_recovery_services_vault_id"></a> [recovery\_services\_vault\_id](#output\_recovery\_services\_vault\_id) | n/a |
| <a name="output_recovery_services_vault_resource"></a> [recovery\_services\_vault\_resource](#output\_recovery\_services\_vault\_resource) | n/a |
| <a name="output_vm_backup_policy_ids"></a> [vm\_backup\_policy\_ids](#output\_vm\_backup\_policy\_ids) | n/a |
| <a name="output_vm_backup_policy_resources"></a> [vm\_backup\_policy\_resources](#output\_vm\_backup\_policy\_resources) | n/a |
<!-- END_TF_DOCS -->