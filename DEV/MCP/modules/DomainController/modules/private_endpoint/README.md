<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm.azurerm_application_provider"></a> [azurerm.azurerm\_application\_provider](#provider\_azurerm.azurerm\_application\_provider) | n/a |
| <a name="provider_azurerm.azurerm_core_infrastructure_provider"></a> [azurerm.azurerm\_core\_infrastructure\_provider](#provider\_azurerm.azurerm\_core\_infrastructure\_provider) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone_virtual_network_link.dns_zone_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_Resource_Group_name"></a> [Resource\_Group\_name](#input\_Resource\_Group\_name) | n/a | `string` | n/a | yes |
| <a name="input_add_dns_zone_vnet_link"></a> [add\_dns\_zone\_vnet\_link](#input\_add\_dns\_zone\_vnet\_link) | n/a | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | n/a | `string` | `""` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | n/a | `string` | `""` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | n/a | `string` | `""` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | n/a | `string` | n/a | yes |
| <a name="input_private_endpoint_service_connection_name"></a> [private\_endpoint\_service\_connection\_name](#input\_private\_endpoint\_service\_connection\_name) | n/a | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | n/a | `string` | n/a | yes |
| <a name="input_private_endpoint_virtual_network_id"></a> [private\_endpoint\_virtual\_network\_id](#input\_private\_endpoint\_virtual\_network\_id) | n/a | `string` | n/a | yes |
| <a name="input_private_endpoint_virtual_network_name"></a> [private\_endpoint\_virtual\_network\_name](#input\_private\_endpoint\_virtual\_network\_name) | n/a | `string` | n/a | yes |
| <a name="input_private_endpoints_ip_configurations"></a> [private\_endpoints\_ip\_configurations](#input\_private\_endpoints\_ip\_configurations) | n/a | <pre>map(object({<br>    name               = string<br>    private_ip_address = string<br>    subresource_name   = string<br>    member_name        = string<br>  }))</pre> | n/a | yes |
| <a name="input_private_resource_id"></a> [private\_resource\_id](#input\_private\_resource\_id) | n/a | `string` | n/a | yes |
| <a name="input_subresource_names"></a> [subresource\_names](#input\_subresource\_names) | n/a | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | n/a |
| <a name="output_private_endpoint_resource"></a> [private\_endpoint\_resource](#output\_private\_endpoint\_resource) | n/a |
<!-- END_TF_DOCS -->