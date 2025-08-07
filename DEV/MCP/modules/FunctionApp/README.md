<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_service_plan_functionapp"></a> [app\_service\_plan\_functionapp](#module\_app\_service\_plan\_functionapp) | Azure/avm-res-web-serverfarm/azurerm | 0.7.0 |
| <a name="module_app_service_plan_functionapp_linux"></a> [app\_service\_plan\_functionapp\_linux](#module\_app\_service\_plan\_functionapp\_linux) | Azure/avm-res-web-serverfarm/azurerm | 0.7.0 |
| <a name="module_function_app_linux"></a> [function\_app\_linux](#module\_function\_app\_linux) | Azure/avm-res-web-site/azurerm | 0.17.2 |
| <a name="module_function_app_windows"></a> [function\_app\_windows](#module\_function\_app\_windows) | Azure/avm-res-web-site/azurerm | 0.17.2 |
| <a name="module_log_analytics_workspace_functionapp"></a> [log\_analytics\_workspace\_functionapp](#module\_log\_analytics\_workspace\_functionapp) | Azure/avm-res-operationalinsights-workspace/azurerm | 0.4.2 |
| <a name="module_metadata-functionapp_Linux_nonprod"></a> [metadata-functionapp\_Linux\_nonprod](#module\_metadata-functionapp\_Linux\_nonprod) | app.terraform.io/Mccain_Foods/azure-metadata/platform | 0.0.11 |
| <a name="module_metadata-functionapp_nonprod"></a> [metadata-functionapp\_nonprod](#module\_metadata-functionapp\_nonprod) | app.terraform.io/Mccain_Foods/azure-metadata/platform | 0.0.11 |
| <a name="module_resource_group-functionapp_nonprod"></a> [resource\_group-functionapp\_nonprod](#module\_resource\_group-functionapp\_nonprod) | app.terraform.io/Mccain_Foods/azure-resource-group/platform | 0.0.1 |
| <a name="module_storage_account_functionapp"></a> [storage\_account\_functionapp](#module\_storage\_account\_functionapp) | Azure/avm-res-storage-storageaccount/azurerm | 0.6.4 |

## Resources

| Name | Type |
|------|------|
| [azurerm_user_assigned_identity.finops-parkingtime-prd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |
| [azurerm_user_assigned_identity.finops_parking_uai](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_app_settings"></a> [additional\_app\_settings](#input\_additional\_app\_settings) | n/a | `map(string)` | `{}` | no |
| <a name="input_application_name_dev"></a> [application\_name\_dev](#input\_application\_name\_dev) | n/a | `string` | n/a | yes |
| <a name="input_blob_soft_delete_retention_days"></a> [blob\_soft\_delete\_retention\_days](#input\_blob\_soft\_delete\_retention\_days) | n/a | `number` | `7` | no |
| <a name="input_built_using"></a> [built\_using](#input\_built\_using) | n/a | `string` | n/a | yes |
| <a name="input_business_owner"></a> [business\_owner](#input\_business\_owner) | n/a | `string` | n/a | yes |
| <a name="input_cfg_aad_client_id"></a> [cfg\_aad\_client\_id](#input\_cfg\_aad\_client\_id) | n/a | `string` | `"bea87b4a-0c2f-4ff3-9fd6-c8d974405587"` | no |
| <a name="input_cfg_aad_client_secret"></a> [cfg\_aad\_client\_secret](#input\_cfg\_aad\_client\_secret) | n/a | `string` | n/a | yes |
| <a name="input_cfg_core_infrastructure_subscription_id"></a> [cfg\_core\_infrastructure\_subscription\_id](#input\_cfg\_core\_infrastructure\_subscription\_id) | n/a | `string` | `"65763622-4bd1-45e6-82fc-2f11e3663439"` | no |
| <a name="input_cfg_tenant_id"></a> [cfg\_tenant\_id](#input\_cfg\_tenant\_id) | n/a | `string` | `"59fa7797-abec-4505-81e6-8ce092642190"` | no |
| <a name="input_environment_dev"></a> [environment\_dev](#input\_environment\_dev) | n/a | `string` | n/a | yes |
| <a name="input_gl_code"></a> [gl\_code](#input\_gl\_code) | n/a | `string` | n/a | yes |
| <a name="input_iac_creator"></a> [iac\_creator](#input\_iac\_creator) | n/a | `string` | n/a | yes |
| <a name="input_iac_owner"></a> [iac\_owner](#input\_iac\_owner) | n/a | `string` | n/a | yes |
| <a name="input_it_owner"></a> [it\_owner](#input\_it\_owner) | n/a | `string` | n/a | yes |
| <a name="input_lob_or_platform"></a> [lob\_or\_platform](#input\_lob\_or\_platform) | n/a | `string` | n/a | yes |
| <a name="input_modified_date"></a> [modified\_date](#input\_modified\_date) | n/a | `string` | n/a | yes |
| <a name="input_network_posture"></a> [network\_posture](#input\_network\_posture) | n/a | `string` | n/a | yes |
| <a name="input_onboarding_date"></a> [onboarding\_date](#input\_onboarding\_date) | n/a | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_terraform_id"></a> [terraform\_id](#input\_terraform\_id) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->