<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_DomainControllers"></a> [DomainControllers](#module\_DomainControllers) | ../../modules/DomainController | n/a |
| <a name="module_image_gallery"></a> [image\_gallery](#module\_image\_gallery) | ../../modules/image_gallery | n/a |
| <a name="module_log_analytics_workspace-image_gallery"></a> [log\_analytics\_workspace-image\_gallery](#module\_log\_analytics\_workspace-image\_gallery) | Azure/avm-res-operationalinsights-workspace/azurerm | 0.4.2 |
| <a name="module_metadata-domain_controller"></a> [metadata-domain\_controller](#module\_metadata-domain\_controller) | app.terraform.io/Mccain_Foods/azure-metadata/platform | 0.0.11 |
| <a name="module_metadata-domain_controller-vm"></a> [metadata-domain\_controller-vm](#module\_metadata-domain\_controller-vm) | app.terraform.io/Mccain_Foods/azure-metadata/platform | 0.0.11 |
| <a name="module_metadata-domain_controller_subnets"></a> [metadata-domain\_controller\_subnets](#module\_metadata-domain\_controller\_subnets) | app.terraform.io/Mccain_Foods/azure-metadata/platform | 0.0.11 |
| <a name="module_metadata-image_gallery"></a> [metadata-image\_gallery](#module\_metadata-image\_gallery) | app.terraform.io/Mccain_Foods/azure-metadata/platform | 0.0.11 |
| <a name="module_resource_group-image_gallery"></a> [resource\_group-image\_gallery](#module\_resource\_group-image\_gallery) | Azure/avm-res-resources-resourcegroup/azurerm | 0.2.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.log_analytics_workspace-image_gallery](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_NIC_subnet_key"></a> [NIC\_subnet\_key](#input\_NIC\_subnet\_key) | Key for the NIC subnet in the domain controller VNet | `string` | `"app"` | no |
| <a name="input_application_name_domain_controllers"></a> [application\_name\_domain\_controllers](#input\_application\_name\_domain\_controllers) | n/a | `string` | `"core"` | no |
| <a name="input_built_using"></a> [built\_using](#input\_built\_using) | n/a | `string` | n/a | yes |
| <a name="input_business_owner"></a> [business\_owner](#input\_business\_owner) | n/a | `string` | n/a | yes |
| <a name="input_cfg_core_infrastructure_subscription_id"></a> [cfg\_core\_infrastructure\_subscription\_id](#input\_cfg\_core\_infrastructure\_subscription\_id) | n/a | `string` | `"65763622-4bd1-45e6-82fc-2f11e3663439"` | no |
| <a name="input_cfg_tenant_id"></a> [cfg\_tenant\_id](#input\_cfg\_tenant\_id) | n/a | `string` | `"59fa7797-abec-4505-81e6-8ce092642190"` | no |
| <a name="input_contributor_access_AD_group_names"></a> [contributor\_access\_AD\_group\_names](#input\_contributor\_access\_AD\_group\_names) | A map of Azure AD group names that will have Contributor access to the Image Gallery. | `map(string)` | <pre>{<br>  "SAP-Infra": "MF-SAP-Infra-PPR-AAD-GRP"<br>}</pre> | no |
| <a name="input_contributor_access_service_principal_object_ids"></a> [contributor\_access\_service\_principal\_object\_ids](#input\_contributor\_access\_service\_principal\_object\_ids) | A map of Azure AD service principal object IDs that will have Contributor access to the Image Gallery. | `map(string)` | `{}` | no |
| <a name="input_contributor_access_user_assigned_managed_identity_object_ids"></a> [contributor\_access\_user\_assigned\_managed\_identity\_object\_ids](#input\_contributor\_access\_user\_assigned\_managed\_identity\_object\_ids) | A map of Azure AD user-assigned managed identity object IDs that will have Contributor access to the Image Gallery. | `map(string)` | `{}` | no |
| <a name="input_default_domain_controller_hostname"></a> [default\_domain\_controller\_hostname](#input\_default\_domain\_controller\_hostname) | Default hostname for the domain controller | `string` | `"nmfazrdc"` | no |
| <a name="input_default_vm_username"></a> [default\_vm\_username](#input\_default\_vm\_username) | Default username for the virtual machines | `string` | `"mccaindcuser"` | no |
| <a name="input_disk_encryption_set_config_key"></a> [disk\_encryption\_set\_config\_key](#input\_disk\_encryption\_set\_config\_key) | n/a | `string` | `"encryption-key"` | no |
| <a name="input_domain_controller_component_name"></a> [domain\_controller\_component\_name](#input\_domain\_controller\_component\_name) | n/a | `string` | `"domaincontroller"` | no |
| <a name="input_domain_controller_password"></a> [domain\_controller\_password](#input\_domain\_controller\_password) | n/a | `string` | n/a | yes |
| <a name="input_domain_controller_private_ip_1"></a> [domain\_controller\_private\_ip\_1](#input\_domain\_controller\_private\_ip\_1) | n/a | `string` | n/a | yes |
| <a name="input_domain_controller_private_ip_2"></a> [domain\_controller\_private\_ip\_2](#input\_domain\_controller\_private\_ip\_2) | n/a | `string` | n/a | yes |
| <a name="input_domain_controller_suffix_1"></a> [domain\_controller\_suffix\_1](#input\_domain\_controller\_suffix\_1) | Suffix for the first domain controller | `string` | n/a | yes |
| <a name="input_domain_controller_suffix_2"></a> [domain\_controller\_suffix\_2](#input\_domain\_controller\_suffix\_2) | Suffix for the second domain controller | `string` | n/a | yes |
| <a name="input_domain_controller_vnet_config"></a> [domain\_controller\_vnet\_config](#input\_domain\_controller\_vnet\_config) | n/a | <pre>object({<br>    vnet_address_space = string,<br>    subnets = map(object({<br>      subnet_identifier = string,<br>      address_space     = string<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_enable_dc_vnet_peering"></a> [enable\_dc\_vnet\_peering](#input\_enable\_dc\_vnet\_peering) | Flag to enable peering between the domain controller VNet and the hub VNet | `bool` | `true` | no |
| <a name="input_encryption_key_name"></a> [encryption\_key\_name](#input\_encryption\_key\_name) | Name of the encryption key to be used for disk encryption | `string` | `"disk-key"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"Production"` | no |
| <a name="input_gl_code"></a> [gl\_code](#input\_gl\_code) | n/a | `string` | n/a | yes |
| <a name="input_hub_vnet_id"></a> [hub\_vnet\_id](#input\_hub\_vnet\_id) | Resource ID of the hub virtual network | `string` | n/a | yes |
| <a name="input_hub_vnet_name"></a> [hub\_vnet\_name](#input\_hub\_vnet\_name) | Name of the hub virtual network | `string` | n/a | yes |
| <a name="input_iac_creator"></a> [iac\_creator](#input\_iac\_creator) | n/a | `string` | n/a | yes |
| <a name="input_iac_owner"></a> [iac\_owner](#input\_iac\_owner) | n/a | `string` | n/a | yes |
| <a name="input_identity_key"></a> [identity\_key](#input\_identity\_key) | Key for the user assigned identity to be used for CMK encryption | `string` | `"mf-core-dc-uaid"` | no |
| <a name="input_image_gallery_name"></a> [image\_gallery\_name](#input\_image\_gallery\_name) | The name of the Image Gallery. | `string` | `""` | no |
| <a name="input_image_gallery_resource_group_name"></a> [image\_gallery\_resource\_group\_name](#input\_image\_gallery\_resource\_group\_name) | The name of the resource group where the Image Gallery will be created. | `string` | `""` | no |
| <a name="input_it_owner"></a> [it\_owner](#input\_it\_owner) | n/a | `string` | n/a | yes |
| <a name="input_key_vault_key"></a> [key\_vault\_key](#input\_key\_vault\_key) | n/a | `string` | `"kv1"` | no |
| <a name="input_key_vault_private_dns_zone_resource_id"></a> [key\_vault\_private\_dns\_zone\_resource\_id](#input\_key\_vault\_private\_dns\_zone\_resource\_id) | Resource ID of the Key Vault private DNS zone | `string` | `"/subscriptions/65763622-4bd1-45e6-82fc-2f11e3663439/resourceGroups/mf_private_endpoint_prod-rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"` | no |
| <a name="input_lob_or_platform"></a> [lob\_or\_platform](#input\_lob\_or\_platform) | n/a | `string` | n/a | yes |
| <a name="input_modified_date"></a> [modified\_date](#input\_modified\_date) | n/a | `string` | n/a | yes |
| <a name="input_network_posture"></a> [network\_posture](#input\_network\_posture) | n/a | `string` | n/a | yes |
| <a name="input_onboarding_date"></a> [onboarding\_date](#input\_onboarding\_date) | n/a | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | n/a | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_key"></a> [private\_endpoint\_subnet\_key](#input\_private\_endpoint\_subnet\_key) | Key for the private endpoint subnet in the domain controller VNet | `string` | `"private-endpoint"` | no |
| <a name="input_reader_access_AD_group_names"></a> [reader\_access\_AD\_group\_names](#input\_reader\_access\_AD\_group\_names) | A map of Azure AD group names that will have Reader access to the Image Gallery. | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_storage_account_private_dns_zone_resource_id"></a> [storage\_account\_private\_dns\_zone\_resource\_id](#input\_storage\_account\_private\_dns\_zone\_resource\_id) | Resource ID of the Storage Account private DNS zone | `string` | `"/subscriptions/65763622-4bd1-45e6-82fc-2f11e3663439/resourceGroups/mf_private_endpoint_prod-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"` | no |
| <a name="input_terraform_id"></a> [terraform\_id](#input\_terraform\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_NIC_subnet_key"></a> [NIC\_subnet\_key](#output\_NIC\_subnet\_key) | n/a |
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | n/a |
| <a name="output_cc_resource_group"></a> [cc\_resource\_group](#output\_cc\_resource\_group) | n/a |
| <a name="output_cc_vnet"></a> [cc\_vnet](#output\_cc\_vnet) | n/a |
| <a name="output_disk_encryption_sets"></a> [disk\_encryption\_sets](#output\_disk\_encryption\_sets) | n/a |
| <a name="output_keyvaults"></a> [keyvaults](#output\_keyvaults) | n/a |
| <a name="output_log_analytics_workspace"></a> [log\_analytics\_workspace](#output\_log\_analytics\_workspace) | n/a |
| <a name="output_nsgs"></a> [nsgs](#output\_nsgs) | n/a |
| <a name="output_private_endpoint_subnet_key"></a> [private\_endpoint\_subnet\_key](#output\_private\_endpoint\_subnet\_key) | n/a |
| <a name="output_recovery_vault_config"></a> [recovery\_vault\_config](#output\_recovery\_vault\_config) | n/a |
| <a name="output_route_tables"></a> [route\_tables](#output\_route\_tables) | n/a |
| <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account) | n/a |
| <a name="output_user_assigned_identities"></a> [user\_assigned\_identities](#output\_user\_assigned\_identities) | n/a |
| <a name="output_virtual_machine_configs"></a> [virtual\_machine\_configs](#output\_virtual\_machine\_configs) | n/a |
<!-- END_TF_DOCS -->