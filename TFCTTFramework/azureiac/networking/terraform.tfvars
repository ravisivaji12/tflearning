cc_resource_groups = {
  "MF_MDIXAI_CC_GH_DSOPS_CORE_RG" = {
    location = "canadacentral"
    tags = {
      CodeOwner   = "ravi.sivaji@mccain.ca"
      Environment = "development"
    }
    lock = {
      level = "CanNotDelete"
      notes = "Lock to prevent deletion of production RG"
    }
  }
  "MF_MDIXAI_CC_GH_DSOPS_STORAGE_RG" = {
    location = "canadacentral"
    tags = {
      CodeOwner   = "ravi.sivaji@mccain.ca"
      Environment = "development"
    }
    lock = {
      level = "CanNotDelete"
      notes = "Readonly lock to monitor access"
    }
  }
}

cc_location                 = "Canada Central"
cc_core_resource_group_name = "MF_MDIXAI_CC_GH_DSOPS_CORE_RG"
enable_telemetry            = false

##################VNET & SUBNET###########################################
cc_vnet = {
  MF_MDIXAI_CC_GH_DSOPS_CORE_VNET = {
    name                = "MF_MDIXAI_CC_GH_DSOPS_CORE_VNET"
    resource_group_name = "MF_MDIXAI_CC_GH_DSOPS_CORE_RG"
    location            = "canadacentral"
    address_space       = ["10.125.176.0/21"]
    subnets = {
      MF_MDIXAI_CC_GH_DSOPS_SQLMI_SNET = {
        name                              = "MF_MDIXAI_CC_GH_DSOPS_SQLMI_SNET"
        address_prefixes                  = ["10.125.181.192/27"]
        service_endpoints                 = []
        default_outbound_access_enabled   = true
        nsg_name                          = "MF_MDIXAI_CC_GH_DSOPS_SQLMI_NSG"
        private_endpoint_network_policies = "Disabled"
        delegation = [{
          name = "sqlMI"
          service_delegation = {
            name    = "Microsoft.Sql/managedInstances"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
          }
        }]
        tags = {
          "Application Name" = "McCain DevSecOps"
        "GL Code" = "N/A" }
      }
      MF_MDIXAI_CC_GH_DSOPS_CAPPS_SNET = {
        name                              = "MF_MDIXAI_CC_GH_DSOPS_CAPPS_SNET"
        address_prefixes                  = ["10.125.176.0/23"]
        nsg_name                          = "MF_MDIXAI_CC_GH_DSOPS_CAPPS_NSG"
        service_endpoints                 = []
        delegation                        = []
        default_outbound_access_enabled   = true
        private_endpoint_network_policies = "Disabled"
      }
      MF_MDIXAI_CC_GH_DSOPS_AFUNC_SNET = {
        name                              = "MF_MDIXAI_CC_GH_DSOPS_AFUNC_SNET"
        private_endpoint_network_policies = "Disabled"
        address_prefixes                  = ["10.125.178.0/24"]
        service_endpoints                 = []
        default_outbound_access_enabled   = true
        delegation = [{
          name = "Microsoft.Web/serverFarms"
          service_delegation = {
            name    = "Microsoft.Web/serverFarms"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action", ]
          }
        }]
      }
      MF_MDIXAI_CC_GH_DSOPS_PLINK_SNET = {

        name                              = "MF_MDIXAI_CC_GH_DSOPS_PLINK_SNET"
        address_prefixes                  = ["10.125.181.0/26"]
        service_endpoints                 = []
        delegation                        = []
        default_outbound_access_enabled   = true
        private_endpoint_network_policies = "Disabled"
      }
      MF_MDIXAI_CC_GH_DSOPS_VMSS_SNET = {
        name                              = "MF_MDIXAI_CC_GH_DSOPS_VMSS_SNET"
        address_prefixes                  = ["10.125.181.224/27"]
        service_endpoints                 = []
        delegation                        = []
        default_outbound_access_enabled   = true
        private_endpoint_network_policies = "Disabled"
        delegation = [{
          name = "Microsoft.StreamAnalytics.streamingJobs"
          service_delegation = {
            name    = "Microsoft.StreamAnalytics/streamingJobs"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", ]
          }
        }]
      }
  } }
  MF_MDIXAI_CC_GH_DSOPS_API_VNET = {
    name                = "MF_MDIXAI_CC_GH_DSOPS_API_VNET"
    resource_group_name = "MF_MDIXAI_CC_GH_DSOPS_CORE_RG"
    location            = "canadacentral"
    address_space       = ["10.125.187.0/24"]
    subnets = {
      MF_MDIXAI_CC_GH_DSOPS_APIM_SNET = {
        name                              = "MF_MDIXAI_CC_GH_DSOPS_APIM_SNET"
        address_prefixes                  = ["10.125.187.64/26"]
        nsg_name                          = "MF_MDIXAI_CC_GH_DSOPS_APIM_NSG"
        service_endpoints                 = ["Microsoft.AzureCosmosDB", "Microsoft.Storage"]
        delegation                        = []
        default_outbound_access_enabled   = true
        private_endpoint_network_policies = "Disabled"
      }
      MF_MDIXAI_CC_GH_DSOPS_APPGW_SNET = {
        name                              = "MF_MDIXAI_CC_GH_DSOPS_APPGW_SNET"
        address_prefixes                  = ["10.125.187.0/26"]
        private_endpoint_network_policies = "Enabled"
        service_endpoints                 = []
        delegation                        = []
        default_outbound_access_enabled   = true
      }
    }
  }
}


###########################NSG###########################################
nsgs = {
  "MF_MDIXAI_CC_GH_DSOPS_SQLMI_NSG" = {
    location            = "canadacentral"
    resource_group_name = "MF_MDIXAI_CC_GH_DSOPS_CORE_RG"
    security_rules = {
      "allow_ssh" = {
        name                       = "allow_ssh"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "10.125.181.192/27"
      },
      "allow_customport_3342" = {
        name                       = "allow_customport_3342"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "10.125.181.192/27"
      },
      "allow_customport_1433" = {
        name                       = "allow_customport_1433"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1433"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "10.125.181.192/27"
      },
      "allow_customport_11000-11999" = {
        name                       = "allow_customport_11000-11999"
        priority                   = 1100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "11000-11999"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "10.125.181.192/27"
      },
      "allow_customport_5022" = {
        name                       = "allow_customport_5022"
        priority                   = 1200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "10.125.181.192/27"
      },
      "allow_customport" = {
        name                       = "allow_customport"
        priority                   = 1300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "3342"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "allow_Outbound_AZCloud" = {
        name                       = "allow_Outbound_AZCloud"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "AzureCloud"
      },
      "allow_Outbound_AAD" = {
        name                       = "allow_Outbound_AAD"
        priority                   = 101
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "AzureActiveDirectory"
      },
      "allow_Outbound_OneDSCollector" = {
        name                       = "allow_Outbound_OneDSCollector"
        priority                   = 102
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "OneDsCollector"
      },
      "allow_Outbound_10.124.77.192_27" = {
        name                       = "allow_Outbound_10.124.77.192_27"
        priority                   = 103
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "10.125.181.192/27"
      },
      "allow_Outbound_StCanadacentral" = {
        name                       = "allow_Outbound_StCanadacentral"
        priority                   = 104
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "Storage.canadacentral"
      },
      "allow_Outbound_StCanadaeast" = {
        name                       = "allow_Outbound_StCanadaeast"
        priority                   = 105
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "Storage.canadaeast"
      },
      "allow_Outbound_Vnet" = {
        name                       = "allow_Outbound_Vnet"
        priority                   = 443
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "VirtualNetwork"
      },
      "allow_Outbound_1433" = {
        name                       = "allow_Outbound_1433"
        priority                   = 1000
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1433"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "VirtualNetwork"
      },
      "allow_Outbound_11000-11999" = {
        name                       = "allow_Outbound_11000-11999"
        priority                   = 1100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "11000-11999"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "VirtualNetwork"
      },
      "allow_Outbound_VirtualNetwork" = {
        name                       = "allow_Outbound_VirtualNetwork"
        priority                   = 1200
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5022"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "VirtualNetwork"
      },
      "allow_Outbound_443" = {
        name                       = "allow_Outbound_443"
        priority                   = 1300
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.125.181.192/27"
        destination_address_prefix = "VirtualNetwork"
      },
      "allow_Outbound_AzureCloud" = {
        name                       = "allow_Outbound_AzureCloud"
        priority                   = 1400
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "AzureCloud"
      }
    }
  },
  "MF_MDIXAI_CC_GH_DSOPS_APPGW_NSG" = {
    location            = "canadacentral"
    resource_group_name = "MF_MDIXAI_CC_GH_DSOPS_CORE_RG"
    security_rules = {
      "AllowInternet" = {
        name                       = "AllowInternet"
        priority                   = 104
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "VirtualNetwork"
      },
      "AllowInternetPowerBI" = {
        name                       = "AllowInternetPowerBI"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "PowerBI"
        destination_address_prefix = "VirtualNetwork"
      },
      "Allowcustom65200-65535" = {
        name                       = "Allowcustom65200-65535"
        priority                   = 115
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      },
      "AllowLoadBalancer" = {
        name                       = "AllowLoadBalancer"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      },
      "DenyAnyCustomAnyInbound" = {
        name                       = "DenyAnyCustomAnyInbound"
        priority                   = 150
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "AllowAnyInternetOut" = {
        name                       = "AllowAnyInternetOut"
        priority                   = 105
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
      },
      "AllowInternet" = {
        name                       = "AllowInternet"
        priority                   = 104
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "VirtualNetwork"
      },
      "AllowInternetPowerBI" = {
        name                       = "AllowInternetPowerBI"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "PowerBI"
        destination_address_prefix = "VirtualNetwork"
      },
      "Allowcustom65200-65535" = {
        name                       = "Allowcustom65200-65535"
        priority                   = 115
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      },
      "AllowLoadBalancer" = {
        name                       = "AllowLoadBalancer"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      },
      "DenyAnyCustomAnyInbound" = {
        name                       = "DenyAnyCustomAnyInbound"
        priority                   = 150
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "AllowAnyInternetOut" = {
        name                       = "AllowAnyInternetOut"
        priority                   = 105
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
      }
    }
  }
  "MF_MDIXAI_CC_GH_DSOPS_AFUNC_NSG" = {
    location            = "canadacentral"
    resource_group_name = "MF_MDIXAI_CC_GH_DSOPS_CORE_RG"
    security_rules = {
      "AllowInternetPowerBI" = {
        name                       = "AllowInternetPowerBI"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "PowerBI"
        destination_address_prefix = "VirtualNetwork"
      },
      "Allowcustom65200-65535" = {
        name                       = "Allowcustom65200-65535"
        priority                   = 115
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      },
      "AllowLoadBalancer" = {
        name                       = "AllowLoadBalancer"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      },
      "DenyAnyCustomAnyInbound" = {
        name                       = "DenyAnyCustomAnyInbound"
        priority                   = 150
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "AllowAnyInternetOut" = {
        name                       = "AllowAnyInternetOut"
        priority                   = 105
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
      },
      "AllowInternet" = {
        name                       = "AllowInternet"
        priority                   = 104
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "VirtualNetwork"
      },
      "AllowInternetPowerBI" = {
        name                       = "AllowInternetPowerBI"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "PowerBI"
        destination_address_prefix = "VirtualNetwork"
      },
      "Allowcustom65200-65535" = {
        name                       = "Allowcustom65200-65535"
        priority                   = 115
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      },
      "AllowLoadBalancer" = {
        name                       = "AllowLoadBalancer"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      },
      "DenyAnyCustomAnyInbound" = {
        name                       = "DenyAnyCustomAnyInbound"
        priority                   = 150
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "AllowAnyInternetOut" = {
        name                       = "AllowAnyInternetOut"
        priority                   = 105
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
      }
    }
  }
}

###########################PUBLIC IP###########################################
# public_ips = {
#   "MF_MDIXAI_CC_GH_DSOPS_APIM_API_IP" = {
#     sku               = "Standard"
#     allocation_method = "Static"
#     domain_name_label = "mfmdixaiccapimpgh"
#   },
#   "MF_MDIXAI_CC_GH_DSOPS_APPGW_IP" = {
#     sku               = "Standard"
#     allocation_method = "Static"
#   }
# }