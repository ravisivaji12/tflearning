# data "azurerm_key_vault_secret" "MF-MDI-CORE-APIMGMT-CER-SSL" {
#   name         = "mfmdcccorecertsecret"
#   key_vault_id = azurerm_key_vault.MF_MDI_CC_CORE-KEY-VAULT.id

#   depends_on = [
#     azurerm_key_vault_access_policy.MF_MDI_CC_CORE_TF_KEY_VAULT_ACCESS_POLICY
#   ]
# }

# resource "azurerm_api_management" "MF-MDI-CC-APIMGT" {
#   name                 = var.cc_core_apimgt_name
#    resource_group_name            = var.cc_core_resource_group_name
#   location                       = var.cc_location
#   publisher_name       = "MCCAIN"
#   publisher_email      = "info@mccain.ca"
#   virtual_network_type = "Internal"

#   sku_name = var.cc_core_apimgt_sku

#   public_ip_address_id = azurerm_public_ip.MF_MDI_CC_APIM_API-IP.id

#   virtual_network_configuration {
#     subnet_id = azurerm_subnet.MF_MDI_CC_APIM-SNET.id
#   }

#   identity {
#     type = "SystemAssigned"
#   }

# #   hostname_configuration {
# #     proxy {
# #       default_ssl_binding = true
# #       host_name           = "${var.cc_core_apim_api_a_record}.${var.cc_core_domain_name}"
# #       key_vault_id        = data.azurerm_key_vault_secret.MF-MDI-CORE-APIMGMT-CER-SSL.versionless_id
# #     }
# #   }
# #   lifecycle {
# #     # prevent_destroy = true
# #     ignore_changes = [hostname_configuration]
# #   }
# }

# resource "azurerm_key_vault_access_policy" "MF_MD_CC_CORE_APIM_KEY_VAULT_ACCESS_POLICY" {
#   key_vault_id = azurerm_key_vault.MF_MDI_CC_CORE-KEY-VAULT.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = azurerm_api_management.MF-MDI-CC-APIMGT.identity[0].principal_id
#   certificate_permissions = [
#     "Get", "List"
#   ]
#   secret_permissions = [
#     "Get", "List"
#   ]
#   key_permissions = [
#     "Get", "List"
#   ]
#   depends_on = [
#     azurerm_key_vault.MF_MDI_CC_CORE-KEY-VAULT,
#     azurerm_api_management.MF-MDI-CC-APIMGT
#   ]
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# resource "azurerm_role_assignment" "MF_MD_CC_CORE_APIM_KEY_VAULT_ROLE_ASSGN" {
#   scope                = azurerm_key_vault.MF_MDI_CC_CORE-KEY-VAULT.id
#   role_definition_name = "Key Vault Administrator"
#   principal_id         = azurerm_api_management.MF-MDI-CC-APIMGT.identity[0].principal_id
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# resource "azurerm_api_management_api" "MF_MDI_CC_API-MdiXAi-Auth-service" {
#   name                = var.cc_core_apimgt_api_name
#   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
#   api_management_name = azurerm_api_management.MF-MDI-CC-APIMGT.name
#   revision            = "1"
#   display_name        = "Auth API"
#   path                = "auth"
#   protocols           = ["https"]
#   service_url         = "https://${azurerm_container_app.MF_MDI_CC-CAPP-MDIXAIAUTHSERVICE.ingress[0].fqdn}"

#   subscription_required = false #change this back to true later

#   import {
#     content_format = "openapi+json-link"
#     content_value  = "https://${azurerm_container_app.MF_MDI_CC-CAPP-MDIXAIAUTHSERVICE.ingress[0].fqdn}/swagger/v1/swagger.json"
#   }

#   lifecycle {
#     prevent_destroy = true
#   }
#   depends_on = [
#     azurerm_container_app.MF_MDI_CC-CAPP-MDIXAIAUTHSERVICE
#   ]
# }

# resource "azurerm_api_management_api_policy" "API_POLICY" {
#   api_name            = azurerm_api_management_api.MF_MDI_CC_API-MdiXAi-Auth-service.name
#   api_management_name = azurerm_api_management.MF-MDI-CC-APIMGT.name
#   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name

#   xml_content = <<XML
# <policies>
#     <inbound>
#         <cors allow-credentials="false">
#             <allowed-origins>
#                 <origin>https://prod-digital-manufacturing.mccain.com</origin>
#                 <origin>http://localhost:4200</origin>
#             </allowed-origins>
#             <allowed-methods preflight-result-max-age="300">
#                 <method>GET</method>
#                 <method>POST</method>
#             </allowed-methods>
#             <allowed-headers>
#                 <header>*</header>
#             </allowed-headers>
#             <expose-headers>
#                 <header>*</header>
#             </expose-headers>
#         </cors>
#         <base />
#         <validate-azure-ad-token header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized" tenant-id="59fa7797-abec-4505-81e6-8ce092642190">
#             <client-application-ids>
#                 <application-id>72761992-27fd-4418-9cd5-078237570fda</application-id>
#                 <!-- If there are multiple client application IDs, then add additional application-id elements -->
#             </client-application-ids>
#             <required-claims>
#                 <claim name="iss" match="any" separator="">
#                     <value>https://sts.windows.net/59fa7797-abec-4505-81e6-8ce092642190/</value>
#                     <!-- if there is more than one allowed value, then add additional value elements -->
#                 </claim>
#                 <!-- if there are multiple possible allowed values, then add additional value elements -->
#             </required-claims>
#         </validate-azure-ad-token>
#     </inbound>
#     <backend>
#         <base />
#     </backend>
#     <outbound>
#         <base />
#     </outbound>
#     <on-error>
#         <base />
#     </on-error>
# </policies>
# XML
# }
# ##Auth service operation policy
# ################################################################################
# # resource "azurerm_api_management_api_operation_policy" "api-GetLanguages-operation-policy" {
# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-MdiXAi-Auth-service.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-settings-GetLanguages"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }

# # resource "azurerm_api_management_api_operation_policy" "api-operation-policy" {
# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-MdiXAi-Auth-service.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-settings-getpositions"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }

# # resource "azurerm_api_management_api_operation_policy" "api-GetShiftByPlantId-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-MdiXAi-Auth-service.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-settings-GetShiftByPlantId"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }
# # ###################################################################################################
# # resource "azurerm_api_management_api" "MF_MDI_CC_DEV_API-mdixaiddds" {

# #   name                = var.cc_core_apimgt_api_ddds
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   revision            = "1"
# #   display_name        = "DDDS"
# #   path                = "dds"
# #   protocols           = ["https"]
# #   service_url         = "https://${azurerm_container_app.MF_MDI_CC_DEV-CAPP-DDDS.ingress[0].fqdn}"

# #   subscription_required = false #change this back to true later

# #   import {
# #     content_format = "openapi+json-link"
# #     content_value  = "https://${azurerm_container_app.MF_MDI_CC_DEV-CAPP-DDDS.ingress[0].fqdn}/swagger/v1/swagger.json"
# #   }

# #   lifecycle {
# #     prevent_destroy = true
# #   }
# #   depends_on = [
# #     azurerm_container_app.MF_MDI_CC_DEV-CAPP-DDDS
# #   ]
# # }

# # resource "azurerm_api_management_api_policy" "API_DDDS_POLICY" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddds.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <cors allow-credentials="false">
# #             <allowed-origins>
# #                 <origin>https://dev-digital-manufacturing.com</origin>
# #                 <origin>http://localhost:4200</origin>
# #             </allowed-origins>
# #             <allowed-methods preflight-result-max-age="300">
# #                 <method>GET</method>
# #                 <method>POST</method>
# #             </allowed-methods>
# #             <allowed-headers>
# #                 <header>*</header>
# #             </allowed-headers>
# #             <expose-headers>
# #                 <header>*</header>
# #             </expose-headers>
# #         </cors>
# #         <base />
# #         <validate-azure-ad-token header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized" tenant-id="59fa7797-abec-4505-81e6-8ce092642190">
# #             <client-application-ids>
# #                 <application-id>9c5751f4-006f-41ba-82a8-38b4f42aa488</application-id>
# #                 <!-- If there are multiple client application IDs, then add additional application-id elements -->
# #             </client-application-ids>
# #             <required-claims>
# #                 <claim name="iss" match="any" separator="">
# #                     <value>https://sts.windows.net/59fa7797-abec-4505-81e6-8ce092642190/</value>
# #                     <!-- if there is more than one allowed value, then add additional value elements -->
# #                 </claim>
# #                 <!-- if there are multiple possible allowed values, then add additional value elements -->
# #             </required-claims>
# #         </validate-azure-ad-token>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML
# # }
# # ##DDDS Operation policy##
# # #################################################################################
# # resource "azurerm_api_management_api_operation_policy" "api-GetUsers-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddds.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-ActionItem-GetUsers"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }


# # resource "azurerm_api_management_api_operation_policy" "api-GetHandoffmasterdataAsync-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddds.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-HandOff-GetHandoffMasterDataAsync"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }

# # resource "azurerm_api_management_api_operation_policy" "api-GetHandOffTemplate-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddds.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-HandOff-GetHandOffTemplate"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }

# # resource "azurerm_api_management_api_operation_policy" "api-GetLines-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddds.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-HandOff-GetLines"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }
# # resource "azurerm_api_management_api_operation_policy" "api-GetShiftTimeByPlantIdAsync-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddds.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-HandOff-GetShiftTimesByPlantIdAsync"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }
# ################################################################################
# resource "azurerm_api_management_api" "MF_MDI_CC_API-mdixaiddh" {

#   name                = var.cc_core_apimgt_api_ddh
#   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
#   api_management_name = azurerm_api_management.MF-MDI-CC-APIMGT.name
#   revision            = "1"
#   display_name        = "DDH"
#   path                = "ddh"
#   protocols           = ["https"]
#   service_url         = "https://${azurerm_container_app.MF_MDI_CC-CAPP-ddh.ingress[0].fqdn}"

#   subscription_required = false #change this back to true later

#   import {
#     content_format = "openapi+json-link"
#     content_value  = "https://${azurerm_container_app.MF_MDI_CC-CAPP-ddh.ingress[0].fqdn}/swagger/v1/swagger.json"
#   }

#   #   lifecycle {
#   #     prevent_destroy = true
#   #   }
#   depends_on = [
#     azurerm_container_app.MF_MDI_CC-CAPP-ddh
#   ]
# }

# resource "azurerm_api_management_api_policy" "API_DDH_POLICY" {

#   api_name            = azurerm_api_management_api.MF_MDI_CC_API-mdixaiddh.name
#   api_management_name = azurerm_api_management.MF-MDI-CC-APIMGT.name
#   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name

#   xml_content = <<XML
# <policies>
#     <inbound>
#         <cors allow-credentials="false">
#             <allowed-origins>
#                 <origin>https://prod-digital-manufacturing.mccain.com</origin>
#                 <origin>http://localhost:4200</origin>
#             </allowed-origins>
#             <allowed-methods preflight-result-max-age="300">
#                 <method>GET</method>
#                 <method>POST</method>
#             </allowed-methods>
#             <allowed-headers>
#                 <header>*</header>
#             </allowed-headers>
#             <expose-headers>
#                 <header>*</header>
#             </expose-headers>
#         </cors>
#         <base />
#         <validate-azure-ad-token header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized" tenant-id="59fa7797-abec-4505-81e6-8ce092642190">
#             <client-application-ids>
#                 <application-id>72761992-27fd-4418-9cd5-078237570fda</application-id>
#                 <!-- If there are multiple client application IDs, then add additional application-id elements -->
#             </client-application-ids>
#             <required-claims>
#                 <claim name="iss" match="any" separator="">
#                     <value>https://sts.windows.net/59fa7797-abec-4505-81e6-8ce092642190/</value>
#                     <!-- if there is more than one allowed value, then add additional value elements -->
#                 </claim>
#                 <!-- if there are multiple possible allowed values, then add additional value elements -->
#             </required-claims>
#         </validate-azure-ad-token>
#     </inbound>
#     <backend>
#         <base />
#     </backend>
#     <outbound>
#         <base />
#     </outbound>
#     <on-error>
#         <base />
#     </on-error>
# </policies>
# XML
# }
# ##DDH Operation policy##
# #################################################################################
# # resource "azurerm_api_management_api_operation_policy" "api-GetAreas-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddh.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-Defects-GetAreas"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }


# # resource "azurerm_api_management_api_operation_policy" "api-GetAssignmentType-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddh.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-Defects-GetAssignmentType"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }

# # resource "azurerm_api_management_api_operation_policy" "api-GetDefectMasterData-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddh.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-Defects-GetDefectMasterData"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }

# # resource "azurerm_api_management_api_operation_policy" "api-GetDefectSubstatuses-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddh.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-Defects-GetDefectSubStatuses"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }
# # resource "azurerm_api_management_api_operation_policy" "api-GetEquipments-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddh.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-Defects-GetEquipments"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }

# # resource "azurerm_api_management_api_operation_policy" "api-defects-GetUsers-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddh.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-Defects-GetUsers"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }
# # resource "azurerm_api_management_api_operation_policy" "api-GetWorkcenters-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaiddh.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-Defects-GetWorkCenters"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }
# #################################################################################
# # resource "azurerm_api_management_api" "MF_MDI_CC_DEV_API-mdixaicid" {

# #   name                = var.cc_core_apimgt_api_cid
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   revision            = "1"
# #   display_name        = "CID"
# #   path                = "cid"
# #   protocols           = ["https"]
# #   service_url         = "https://${azurerm_container_app.MF_MDI_CC_DEV-CAPP-cid.ingress[0].fqdn}"

# #   subscription_required = false #change this back to true later

# #   import {
# #     content_format = "openapi+json-link"
# #     content_value  = "https://${azurerm_container_app.MF_MDI_CC_DEV-CAPP-cid.ingress[0].fqdn}/swagger/v1/swagger.json"
# #   }

# #   lifecycle {
# #     prevent_destroy = true
# #   }
# #   depends_on = [
# #     azurerm_container_app.MF_MDI_CC_DEV-CAPP-cid
# #   ]
# # }

# # resource "azurerm_api_management_api_policy" "API_cid_POLICY" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaicid.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <cors allow-credentials="false">
# #             <allowed-origins>
# #                 <origin>https://dev-digital-manufacturing.com</origin>
# #                 <origin>http://localhost:4200</origin>
# #             </allowed-origins>
# #             <allowed-methods preflight-result-max-age="300">
# #                 <method>GET</method>
# #                 <method>POST</method>
# #                 <method>PUT</method>
# #             </allowed-methods>
# #             <allowed-headers>
# #                 <header>*</header>
# #             </allowed-headers>
# #             <expose-headers>
# #                 <header>*</header>
# #             </expose-headers>
# #         </cors>
# #         <base />
# #         <validate-azure-ad-token header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized" tenant-id="59fa7797-abec-4505-81e6-8ce092642190">
# #             <client-application-ids>
# #                 <application-id>9c5751f4-006f-41ba-82a8-38b4f42aa488</application-id>
# #                 <!-- If there are multiple client application IDs, then add additional application-id elements -->
# #             </client-application-ids>
# #             <required-claims>
# #                 <claim name="iss" match="any" separator="">
# #                     <value>https://sts.windows.net/59fa7797-abec-4505-81e6-8ce092642190/</value>
# #                     <!-- if there is more than one allowed value, then add additional value elements -->
# #                 </claim>
# #                 <!-- if there are multiple possible allowed values, then add additional value elements -->
# #             </required-claims>
# #         </validate-azure-ad-token>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML
# # }
# # ##CID Operation policy##
# # #################################################################################
# # resource "azurerm_api_management_api_operation_policy" "api-GetAreaDetails-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaicid.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-Area-GetAreaDetails"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }


# # resource "azurerm_api_management_api_operation_policy" "api-GetCategoryList-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaicid.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-Category-GetCategoryList"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }

# # resource "azurerm_api_management_api_operation_policy" "api-GetShifts-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaicid.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-Common-GetShifts"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }

# # resource "azurerm_api_management_api_operation_policy" "api-GetPositionsList-operation-policy" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaicid.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   operation_id        = "get-api-RouteProcess-GetPositionsList"

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <base />
# #         <!-- Remove Cache-Control header from the request -->
# #         <set-header name="Cache-Control" exists-action="delete" />
# #         <!-- Cache lookup policy -->
# #         <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" allow-private-response-caching="true" must-revalidate="true" downstream-caching-type="none" caching-type="internal">
# #             <vary-by-header>Accept</vary-by-header>
# #             <vary-by-header>Accept-Charset</vary-by-header>
# #         </cache-lookup>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #         <!-- Cache store policy with specified duration -->
# #         <cache-store duration="60" />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML

# # }
# # #########################################################################################################
# # resource "azurerm_api_management_api" "MF_MDI_CC_DEV_API-mdixaidcl" {

# #   name                = var.cc_core_apimgt_api_dcl
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   revision            = "1"
# #   display_name        = "DCL"
# #   path                = "dcl"
# #   protocols           = ["https"]
# #   service_url         = "https://${azurerm_container_app.MF_MDI_CC_DEV-CAPP-dcl.ingress[0].fqdn}"

# #   subscription_required = false #change this back to true later

# #   import {
# #     content_format = "openapi+json-link"
# #     content_value  = "https://${azurerm_container_app.MF_MDI_CC_DEV-CAPP-dcl.ingress[0].fqdn}/swagger/v1/swagger.json"
# #   }

# #   lifecycle {
# #     prevent_destroy = true
# #   }
# #   depends_on = [
# #     azurerm_container_app.MF_MDI_CC_DEV-CAPP-dcl
# #   ]
# # }

# # resource "azurerm_api_management_api_policy" "API_dcl_POLICY" {

# #   api_name            = azurerm_api_management_api.MF_MDI_CC_DEV_API-mdixaidcl.name
# #   api_management_name = azurerm_api_management.MF-MDI-CC-DEV-APIMGT.name
# #   resource_group_name = azurerm_resource_group.MF_MDI_CC-RG.name

# #   xml_content = <<XML
# # <policies>
# #     <inbound>
# #         <cors allow-credentials="false">
# #             <allowed-origins>
# #                 <origin>https://dev-digital-manufacturing.com</origin>
# #                 <origin>http://localhost:4200</origin>
# #             </allowed-origins>
# #             <allowed-methods preflight-result-max-age="300">
# #                 <method>GET</method>
# #                 <method>POST</method>
# #                 <method>PUT</method>
# #             </allowed-methods>
# #             <allowed-headers>
# #                 <header>*</header>
# #             </allowed-headers>
# #             <expose-headers>
# #                 <header>*</header>
# #             </expose-headers>
# #         </cors>
# #         <base />
# #         <validate-azure-ad-token header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized" tenant-id="59fa7797-abec-4505-81e6-8ce092642190">
# #             <client-application-ids>
# #                 <application-id>9c5751f4-006f-41ba-82a8-38b4f42aa488</application-id>
# #                 <!-- If there are multiple client application IDs, then add additional application-id elements -->
# #             </client-application-ids>
# #             <required-claims>
# #                 <claim name="iss" match="any" separator="">
# #                     <value>https://sts.windows.net/59fa7797-abec-4505-81e6-8ce092642190/</value>
# #                     <!-- if there is more than one allowed value, then add additional value elements -->
# #                 </claim>
# #                 <!-- if there are multiple possible allowed values, then add additional value elements -->
# #             </required-claims>
# #         </validate-azure-ad-token>
# #     </inbound>
# #     <backend>
# #         <base />
# #     </backend>
# #     <outbound>
# #         <base />
# #     </outbound>
# #     <on-error>
# #         <base />
# #     </on-error>
# # </policies>
# # XML
# # }  