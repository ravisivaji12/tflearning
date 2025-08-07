<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread.azuread_mccaingroup_onmicrosoft_com"></a> [azuread.azuread\_mccaingroup\_onmicrosoft\_com](#provider\_azuread.azuread\_mccaingroup\_onmicrosoft\_com) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_image_gallery"></a> [image\_gallery](#module\_image\_gallery) | Azure/avm-res-compute-gallery/azurerm | 0.2.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_group.contributor_groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.reader_groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_contributor_access_AD_group_names"></a> [contributor\_access\_AD\_group\_names](#input\_contributor\_access\_AD\_group\_names) | A map of Azure AD group names that will have Contributor access to the Image Gallery. | `map(string)` | `{}` | no |
| <a name="input_contributor_access_service_principal_object_ids"></a> [contributor\_access\_service\_principal\_object\_ids](#input\_contributor\_access\_service\_principal\_object\_ids) | A map of Azure AD service principal object IDs that will have Contributor access to the Image Gallery. | `map(string)` | `{}` | no |
| <a name="input_contributor_access_user_assigned_managed_identity_object_ids"></a> [contributor\_access\_user\_assigned\_managed\_identity\_object\_ids](#input\_contributor\_access\_user\_assigned\_managed\_identity\_object\_ids) | A map of Azure AD user-assigned managed identity object IDs that will have Contributor access to the Image Gallery. | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | n/a | `string` | `"McCain Default Image Gallery"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Image Gallery will be created. | `string` | n/a | yes |
| <a name="input_lock"></a> [lock](#input\_lock) | An optional lock configuration for the Image Gallery. | <pre>object({<br>    kind = string<br>    name = optional(string, null)<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Image Gallery. | `string` | n/a | yes |
| <a name="input_reader_access_AD_group_names"></a> [reader\_access\_AD\_group\_names](#input\_reader\_access\_AD\_group\_names) | A map of Azure AD group names that will have Reader access to the Image Gallery. | `map(string)` | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Image Gallery will be created. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the Image Gallery. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_gallery_id"></a> [image\_gallery\_id](#output\_image\_gallery\_id) | n/a |
<!-- END_TF_DOCS -->