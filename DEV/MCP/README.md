# mf-core-paltform for Creating platform related components
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
| <a name="module_FunctionApp-FinOpsParking"></a> [FunctionApp-FinOpsParking](#module\_FunctionApp-FinOpsParking) | ./modules/FunctionApp/ | n/a |
| <a name="module_regional_platform_infrastructure"></a> [regional\_platform\_infrastructure](#module\_regional\_platform\_infrastructure) | ./modules/regional_platform_infra | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_security_center_subscription_pricing.defender_enablement](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_finops_parking_function_app_settings"></a> [additional\_finops\_parking\_function\_app\_settings](#input\_additional\_finops\_parking\_function\_app\_settings) | n/a | `map(string)` | `{}` | no |
| <a name="input_application_name_dev"></a> [application\_name\_dev](#input\_application\_name\_dev) | n/a | `string` | n/a | yes |
| <a name="input_blob_soft_delete_retention_days"></a> [blob\_soft\_delete\_retention\_days](#input\_blob\_soft\_delete\_retention\_days) | n/a | `number` | `7` | no |
| <a name="input_built_using"></a> [built\_using](#input\_built\_using) | n/a | `string` | n/a | yes |
| <a name="input_business_owner"></a> [business\_owner](#input\_business\_owner) | n/a | `string` | n/a | yes |
| <a name="input_cfg_aad_client_id"></a> [cfg\_aad\_client\_id](#input\_cfg\_aad\_client\_id) | n/a | `string` | `"bea87b4a-0c2f-4ff3-9fd6-c8d974405587"` | no |
| <a name="input_cfg_aad_client_secret"></a> [cfg\_aad\_client\_secret](#input\_cfg\_aad\_client\_secret) | n/a | `string` | n/a | yes |
| <a name="input_cfg_core_infrastructure_subscription_id"></a> [cfg\_core\_infrastructure\_subscription\_id](#input\_cfg\_core\_infrastructure\_subscription\_id) | n/a | `string` | `"65763622-4bd1-45e6-82fc-2f11e3663439"` | no |
| <a name="input_cfg_tenant_id"></a> [cfg\_tenant\_id](#input\_cfg\_tenant\_id) | n/a | `string` | `"59fa7797-abec-4505-81e6-8ce092642190"` | no |
| <a name="input_defender_plans"></a> [defender\_plans](#input\_defender\_plans) | Map of Defender plans | <pre>map(object(<br>    {<br>      resource_type = string<br>      sub_plan      = optional(string, null)<br>      extensions = optional(map(object({<br>        name                  = string<br>        additional_properties = optional(map(string), {})<br>      })), {})<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"Production"` | no |
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
| <a name="input_platform_infrastructure_regional_footprint"></a> [platform\_infrastructure\_regional\_footprint](#input\_platform\_infrastructure\_regional\_footprint) | Map of regional footprints for platform infrastructure. This allows setting up the infrastructure in a new region quickly without requiring addition of a lot of code or config | <pre>map(object({<br>    domain_controller_vnet_config = object({<br>      vnet_address_space = string,<br>      subnets = map(object({<br>        subnet_identifier = string,<br>        address_space     = string<br>      }))<br>    })<br>    domain_controller_private_ip_1    = string<br>    domain_controller_private_ip_2    = string<br>    domain_controller_password        = string<br>    domain_controller_suffix_1        = string<br>    domain_controller_suffix_2        = string<br>    hub_vnet_name                     = string<br>    hub_vnet_id                       = string<br>    image_gallery_resource_group_name = string<br>    image_gallery_name                = string<br>    enable_dc_vnet_peering            = optional(bool, true)<br>  }))</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_terraform_id"></a> [terraform\_id](#input\_terraform\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_controller_passwords"></a> [domain\_controller\_passwords](#output\_domain\_controller\_passwords) | n/a |
<!-- END_TF_DOCS -->

## Known Issues
### 1. False positive delta: Removal of "hidden-link: /app-insights-resource-id" tag
As the app insights configuration for the function app automatically adds the app insights resource ID hidden tag as a result of the application insights configuration, every plan will show this tag's removal as a delta. But we should just ignore it, as it will automatically get added back again. Since the application insights is being created as a part of the AVM module and note separately, it is not possible for us to find the resource ID of this in advance, and hecen we cannot add the tag.