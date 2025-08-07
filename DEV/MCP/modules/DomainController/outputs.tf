output "cc_rg_outputs" {
  value = {
    name = module.MF_MDI_CC_RG.name
    id   = module.MF_MDI_CC_RG.resource_id
  }
}

# output "cc_rg_locks" {
#   value = {
#     for k, v in azurerm_management_lock.rg_locks :
#     k => v.lock_level
#   }
# }

# ### Virtual Network #####
output "vnet_info" {
  description = "Information about all virtual networks"
  value = {
    name                 = module.avm-res-network-virtualnetwork.name
    id                   = module.avm-res-network-virtualnetwork.resource_id
    location             = module.avm-res-network-virtualnetwork.resource.location
    address_space        = module.avm-res-network-virtualnetwork.resource.body.properties.addressSpace.addressPrefixes
    ddosProtectionPlan   = module.avm-res-network-virtualnetwork.resource.body.properties.ddosProtectionPlan
    dhcpOptions          = module.avm-res-network-virtualnetwork.resource.body.properties.dhcpOptions
    enableDdosProtection = module.avm-res-network-virtualnetwork.resource.body.properties.enableDdosProtection
    enableVmProtection   = module.avm-res-network-virtualnetwork.resource.body.properties.enableVmProtection
    encryption           = module.avm-res-network-virtualnetwork.resource.body.properties.encryption
    tags                 = module.avm-res-network-virtualnetwork.resource.tags
    # Commenting as subnets is not found in the properties
    # subnets = {
    #   for subnet_name, subnet in module.avm-res-network-virtualnetwork.resource.body.properties.subnets : subnet_name => {
    #     subnet_name                       = subnet_name
    #     subnet_id                         = subnet.resource_id
    #     addressPrefix                     = subnet.resource.body.properties.addressPrefix
    #     defaultOutboundAccess             = subnet.resource.body.properties.defaultOutboundAccess
    #     delegations                       = subnet.resource.body.properties.delegations
    #     natGateway                        = subnet.resource.body.properties.natGateway
    #     networkSecurityGroup              = subnet.resource.body.properties.networkSecurityGroup
    #     privateEndpointNetworkPolicies    = subnet.resource.body.properties.privateEndpointNetworkPolicies
    #     privateLinkServiceNetworkPolicies = subnet.resource.body.properties.privateLinkServiceNetworkPolicies
    #     routeTable                        = subnet.resource.body.properties.routeTable
    #     serviceEndpointPolicies           = subnet.resource.body.properties.serviceEndpointPolicies
    #     serviceEndpoints                  = subnet.resource.body.properties.serviceEndpoints
    #     tags                              = subnet.resource.tags
    #   }
    # }
  }
}

output "cc_nsg_info" {
  description = "info for all NSGs"
  value = {
    for k, mod in module.nsg :
    k => {
      id                  = mod.resource_id
      name                = mod.name
      location            = mod.resource.location
      security_rule       = mod.resource.security_rule
      resource_group_name = mod.resource.resource_group_name
      tags                = mod.resource.tags
    }
  }
}

output "cc_route_info" {
  description = "info for all route tables info"
  value = {
    for k, mod in module.MF_MDI-rt :
    k => {
      id                  = mod.resource_id
      name                = mod.name
      location            = mod.resource.location
      routes              = mod.routes
      resource_group_name = mod.resource.resource_group_name
      tags                = mod.resource.tags
    }
  }
}

output "password" {
  value     = random_password.admin_password.result
  sensitive = true
}

# output "network_interfaces" {
#   value = {
#     for k, mod in module.avm-res-network-networkinterface :
#     k => {
#       id                    = mod.resource_id
#       name                  = mod.resource.name
#       ip_forwarding_enabled = mod.resource.ip_forwarding_enabled
#       location              = mod.resource.location
#       mac_address           = mod.resource.mac_address
#       private_ip_address    = mod.resource.private_ip_address
#       private_ip_addresses  = mod.resource.private_ip_addresses
#       resource_group_name   = mod.resource.resource_group_name
#       tags                  = mod.resource.tags
#       ip_configurations = [
#         for ip in mod.resource.ip_configuration : {
#           gateway_load_balancer_frontend_ip_configuration_id = ip.gateway_load_balancer_frontend_ip_configuration_id
#           name                                               = ip.name
#           primary                                            = ip.primary
#           private_ip_address                                 = ip.private_ip_address
#           private_ip_address_allocation                      = ip.private_ip_address_allocation
#           private_ip_address_version                         = ip.private_ip_address_version
#           public_ip_address_id                               = ip.public_ip_address_id
#           subnet_id                                          = ip.subnet_id
#         }
#       ]
#     }
#   }
# }

# output "vault_ids" {
#   description = "IDs of all Recovery Services Vaults"
#   value       = { for k, v in module.azure_recovery_services_vault : k => v.resource_id }
# }

# output "vault_names" {
#   description = "Names of the Vaults"
#   value       = [for k, v in module.azure_recovery_services_vault : v.resource.name]
# }

# output "vault_locations" {
#   description = "Locations of the Vaults"
#   value       = [for k, v in module.azure_recovery_services_vault : v.resource.location]
# }

# output "vault_rg_names" {
#   description = "Resource Groups for each vault"
#   value       = [for k, v in module.azure_recovery_services_vault : v.resource.resource_group_name]
# }












