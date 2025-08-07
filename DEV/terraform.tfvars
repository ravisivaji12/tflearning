cc_location                    = "Canada Central"
cc_core_resource_group_name    = "MF_MDIxMI_Github_PROD_RG"
cc_storage_resource_group_name = "MF_MDI_CC_GH_STORAGE-PROD-RG"

###########################KV###########################################
kv_name                         = "MF-MDI-CORE-PRDGH-KV"
sku_name                        = "standard"
soft_delete_retention_days      = 7
purge_protection_enabled        = false
public_network_access_enabled   = true
enabled_for_deployment          = false
enabled_for_disk_encryption     = false
enabled_for_template_deployment = false
enable_rbac_authorization       = true


##################VNET & SUBNET###########################################
cc_vnet = {
  MF_MDI_CC_PROD_CORE-VNET = {
    name                = "MF_MDI_CC_PROD_CORE-VNET"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"
    location            = "canadacentral"
    address_space       = ["10.125.176.0/21"]
    subnets = {
      MF_MDI_CC_PROD_SQLMI-SNET = {
        name                              = "MF_MDI_CC_PROD_SQLMI-SNET"
        address_prefixes                  = ["10.125.181.192/27"]
        service_endpoints                 = []
        nsg_name                          = "MF_MDI_CC_SQLMI-NSG"
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
      MF_MDI_CC_CAPPS-SNET = {
        name                              = "MF_MDI_CC_CAPPS-SNET"
        address_prefixes                  = ["10.125.176.0/23"]
        nsg_name                          = "MF_MDI_CC_CAPPS-NSG"
        service_endpoints                 = []
        delegation                        = []
        private_endpoint_network_policies = "Disabled"
      }
      MF_MDI_CC_AFUNC-SNET = {
        name                              = "MF_MDI_CC_AFUNC-SNET"
        private_endpoint_network_policies = "Disabled"
        address_prefixes                  = ["10.125.178.0/24"]
        service_endpoints                 = []
        delegation = [{
          name = "Microsoft.Web/serverFarms"
          service_delegation = {
            name    = "Microsoft.Web/serverFarms"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action", ]
          }
        }]
      }
      MF_MDI_CC_PLINK-SNET = {

        name                              = "MF_MDI_CC_PLINK-SNET"
        address_prefixes                  = ["10.125.181.0/26"]
        service_endpoints                 = []
        delegation                        = []
        private_endpoint_network_policies = "Disabled"
      }
      MF_MDI_CC_VMSS-SNET = {
        name                              = "MF_MDI_CC_VMSS-SNET"
        address_prefixes                  = ["10.125.181.224/27"]
        service_endpoints                 = []
        delegation                        = []
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
  MF_MDI_CC_PROD_API-VNET = {
    name                = "MF_MDI_CC_PROD_API-VNET"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"
    location            = "canadacentral"
    address_space       = ["10.125.187.0/24"]
    subnets = {
      MF_MDI_CC_APIM-SNET = {
        name                              = "MF_MDI_CC_APIM-SNET"
        address_prefixes                  = ["10.125.187.64/26"]
        nsg_name                          = "MF_MDI_CC_APIM-NSG"
        service_endpoints                 = ["Microsoft.AzureCosmosDB", "Microsoft.Storage"]
        delegation                        = []
        private_endpoint_network_policies = "Disabled"
      }
      MF_MDI_CC_APPGW-SNET = {
        name                              = "MF_MDI_CC_APPGW-SNET"
        address_prefixes                  = ["10.125.187.0/26"]
        private_endpoint_network_policies = "Enabled"
        service_endpoints                 = []
        delegation                        = []
      }
    }
  }
}


###########################NSG###########################################
nsgs = {
  "MF_MDI_CC_SQLMI-NSG" = {
    location            = "canadacentral"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"
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
  "MF_MDI_CC_PROD_APPGW-NSG" = {
    location            = "canadacentral"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"
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
  "MF_MDI_CC_AFUNC-NSG" = {
    location            = "canadacentral"
    resource_group_name = "MF_MDIxMI_Github_PROD_RG"
    security_rules = {
      "allowcosmosDB" = {
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
}

###########################PUBLIC IP###########################################
public_ips = {
  "MF_MDI_CC_APIM_PROD_API-IP" = {
    sku               = "Standard"
    allocation_method = "Static"
    domain_name_label = "mfmdiccapimprodgithub"
  },
  "prod-appgw-public-ip" = {
    sku               = "Standard"
    allocation_method = "Static"
  }
}


###########################LOG Analytics###########################################

cc_core_law_name = "MF-MDI-CC-CORE-PROD-LAW"
cc_core_law_sku  = "PerGB2018"


############################Web App###########################################
MF_DM_CC_CORE-appSP_Name  = "MF_DM_CC_CORE_PROD-appSP"
MF-DM-CC-CORE-Webapp_Name = "MF-MDI-CC-CORE-PROD-Webapp-GITHUB"


############################ACR############################
cc_core_acr_name = "MFMDICCCOREPRODACRGITHUB"
cc_core_acr_sku  = "Basic"

############################Container App############################
MF_MDI_CC-CAPPENV_NAME = "mf-mdi-cc-prod-cappenv"



##############################APIM##############################
cc_core_apimgt_name = "mf-mdi-cc-ghprod-APIMGT"
cc_core_apimgt_sku  = "Developer_1"

################### Application Insights #######################

cc_core_appinsights_name = "MF-MDI-CC-CORE-APP-INSIGHTS"

#################### Azure App Service Plan #######################


cc_core_app_service_plans = {
  name                = "MFDMCCDEVASPAFUNC"
  location            = "Canada Central"
  resource_group_name = "MF_MDIxMI_Github_PROD_RG"
  kind                = "FunctionApp"
  sku = {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

#################### Azure Functions #######################

cc_core_function_apps = {
  MF-DM-CC-DDDS-AFUNC = {
    name                        = "MF-DM-CC-DDDS-AFUNC"
    location                    = "Canada Central"
    os_type                     = "Windows"
    storage_account_name        = "mfmdiccsaname"
    storage_account_rg          = "MF_MDI_CC_GH_STORAGE-PROD-RG"
    network_name                = "MF_MDI_CC_PROD_CORE-VNET"
    subnet_name                 = "MF_MDI_CC_AFUNC-SNET"
    user_assigned_identity_name = "MF_CC_CORE_PROD_APP_ACCESS-USER-IDENTITY"
    user_assigned_identity_rg   = "MF_MDIxMI_Github_PROD_RG"
    app_insights_name           = "MF-MDI-CC-CORE-APP-INSIGHTS"
    app_insights_rg             = "MF_MDIxMI_Github_PROD_RG"
    key_vault_name              = "MF-MDI-CORE-PRD-GH-KV"
    additional_app_settings = {
      DddsBatchTriggerTime            = "0 0/5 * * * *"
      FUNCTIONS_WORKER_RUNTIME        = "dotnet-isolated"
      mdiaikeyVaultName               = "MF-DM-CC-CORE-DEV-KV"
      mdiaiTenantId                   = "59fa7797-abec-4505-81e6-8ce092642190"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
      WEBSITE_RUN_FROM_PACKAGE        = "1"
    }
  }

  MF-DM-CC-EXTERNALDATA-AFUNC = {
    name                        = "MF-DM-CC-EXTERNALDATA-AFUNC"
    location                    = "Canada Central"
    os_type                     = "Windows"
    storage_account_name        = "mfmdiccsaname"
    storage_account_rg          = "MF_MDI_CC_GH_STORAGE-PROD-RG"
    network_name                = "MF_MDI_CC_PROD_CORE-VNET"
    subnet_name                 = "MF_MDI_CC_AFUNC-SNET"
    user_assigned_identity_name = "MF_CC_CORE_PROD_APP_ACCESS-USER-IDENTITY"
    user_assigned_identity_rg   = "MF_MDIxMI_Github_PROD_RG"
    app_insights_name           = "MF-MDI-CC-CORE-APP-INSIGHTS"
    app_insights_rg             = "MF_MDIxMI_Github_PROD_RG"
    key_vault_name              = "MF-MDI-CORE-PRD-GH-KV"
    additional_app_settings = {
      DddsBatchTriggerTime            = "0 0/5 * * * *"
      FUNCTIONS_WORKER_RUNTIME        = "dotnet-isolated"
      mdiaikeyVaultName               = "MF-DM-CC-CORE-DEV-KV"
      mdiaiTenantId                   = "59fa7797-abec-4505-81e6-8ce092642190"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
      WEBSITE_RUN_FROM_PACKAGE        = "1"
      WorkOrderStatusTriggerTime      = "0 0/15 * * * *"
      EquipmentStopTriggerTime        = "0 0/15 * * * *"
      SKUBatchTriggerTime             = "0 0/5 * * * *"
    }
  }

  MF-MDI-CC-LIVESKU-AFUNC = {
    name                        = "MF-MDI-CC-LIVESKU-AFUNC"
    location                    = "Canada Central"
    os_type                     = "Windows"
    storage_account_name        = "mfmdiccsaname"
    storage_account_rg          = "MF_MDI_CC_GH_STORAGE-PROD-RG"
    network_name                = "MF_MDI_CC_PROD_CORE-VNET"
    subnet_name                 = "MF_MDI_CC_AFUNC-SNET"
    user_assigned_identity_name = "MF_CC_CORE_PROD_APP_ACCESS-USER-IDENTITY"
    user_assigned_identity_rg   = "MF_MDIxMI_Github_PROD_RG"
    app_insights_name           = "MF-MDI-CC-CORE-APP-INSIGHTS"
    app_insights_rg             = "MF_MDIxMI_Github_PROD_RG"
    key_vault_name              = "MF-MDI-CORE-PRD-GH-KV"
    additional_app_settings = {
      DddsBatchTriggerTime               = "0 0/5 * * * *"
      FUNCTIONS_WORKER_RUNTIME           = "dotnet-isolated"
      mdiaikeyVaultName                  = "MF-DM-CC-CORE-DEV-KV"
      mdiaiTenantId                      = "59fa7797-abec-4505-81e6-8ce092642190"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE    = "true"
      WEBSITE_RUN_FROM_PACKAGE           = "1"
      mdiaiLiveSkuEVHConnectionString    = "@Microsoft.KeyVault(SecretUri=https://MF-DM-CC-CORE-DEV-KV.vault.azure.net/secrets/mdiaiLiveSkuEVHConnectionStringCDL/)"
      mdiaiLiveSkuEVHConsumerGrp         = "ehentity-skudata-stg2-cg1"
      mdiaiLiveSkuEVHName                = "mf-mdi-cc-skudata-stg2"
      mdiaiLineStatusEVHConnectionString = "@Microsoft.KeyVault(SecretUri=https://MF-DM-CC-CORE-DEV-KV.vault.azure.net/secrets/mdiaiLineStatusEVHConnectionStringCDL/)"
      mdiaiLineStatusEVHConsumerGrp      = "ehentity-linestatus-stg2-cg1"
      mdiaiLineStatusEVHName             = "mf-mdi-cc-linestatus-stg2"
      Authority                          = "https://login.microsoftonline.com/59fa7797-abec-4505-81e6-8ce092642190"
      Scope                              = "https://piwebdev-mccaingroup.msappproxy.net/user_impersonation"
      PiApiUrl                           = "https://piwebdev-mccaingroup.msappproxy.net"
      LiveSKUTriggerTime                 = "0 * * * *"
    }
  }

  MF-MDI-CC-AUTO-SUBM-AFUNC = {
    name                        = "MF-MDI-CC-AUTO-SUBM-AFUNC"
    location                    = "Canada Central"
    os_type                     = "Windows"
    storage_account_name        = "mfmdiccsaname"
    storage_account_rg          = "MF_MDI_CC_GH_STORAGE-PROD-RG"
    network_name                = "MF_MDI_CC_PROD_CORE-VNET"
    subnet_name                 = "MF_MDI_CC_AFUNC-SNET"
    user_assigned_identity_name = "MF_CC_CORE_PROD_APP_ACCESS-USER-IDENTITY"
    user_assigned_identity_rg   = "MF_MDIxMI_Github_PROD_RG"
    app_insights_name           = "MF-MDI-CC-CORE-APP-INSIGHTS"
    app_insights_rg             = "MF_MDIxMI_Github_PROD_RG"
    key_vault_name              = "MF-MDI-CORE-PRD-GH-KV"
    additional_app_settings = {
      DddsBatchTriggerTime            = "0 0/5 * * * *"
      FUNCTIONS_WORKER_RUNTIME        = "dotnet-isolated"
      mdiaikeyVaultName               = "MF-DM-CC-CORE-DEV-KV"
      mdiaiTenantId                   = "59fa7797-abec-4505-81e6-8ce092642190"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
      WEBSITE_RUN_FROM_PACKAGE        = "1"
    }
  }
}

# kv_legacy_access_policies = {
#   "MF_MDI_CC_CORE_TF_KEY_VAULT_ACCESS_POLICY" = {
#     tenant_id               = "00000000-0000-0000-0000-000000000000"
#     object_id               = "11111111-1111-1111-1111-111111111111"
#     secret_permissions      = ["Get", "List"]
#     key_permissions         = ["Get", "List"]
#     certificate_permissions = ["Get", "List", "GetIssuers", "ListIssuers"]
#     storage_permissions     = ["Get", "List"]
#   }
#   "MF_MDI_CC_CORE_ACA_AUTH_KEY_VAULT_ACCESS_POLICY" = {
#     tenant_id               = "00000000-0000-0000-0000-000000000000"
#     object_id               = "11111111-1111-1111-1111-111111111111"
#     secret_permissions      = ["Get", "List"]
#     key_permissions         = ["Get", "List"]
#     certificate_permissions = ["Get", "List", "GetIssuers", "ListIssuers"]
#     storage_permissions     = []
#   }
#   "MF_MDI_CC_CORE_ACA_DDH_KEY_VAULT_ACCESS_POLICY" = {
#     tenant_id               = "00000000-0000-0000-0000-000000000000"
#     object_id               = "11111111-1111-1111-1111-111111111111"
#     secret_permissions      = ["Get", "List"]
#     key_permissions         = ["Get", "List"]
#     certificate_permissions = ["Get", "List", "GetIssuers", "ListIssuers"]
#     storage_permissions     = []
#   }
#   "MF_MDI_CC_CORE_KEY_VAULT_ACCESS_POLICY" = {
#     tenant_id               = "00000000-0000-0000-0000-000000000000"
#     object_id               = "11111111-1111-1111-1111-111111111111"
#     secret_permissions      = ["Get", "List"]
#     key_permissions         = ["Get", "List"]
#     certificate_permissions = ["Get", "List", "GetIssuers", "ListIssuers"]
#     storage_permissions     = []
#   }
# }

# kv_role_assignments = {
#   "MF_MDI_CC_CORE_ACA_AUTH_KEY_VAULT_ROLE_ASSGN" = {
#     role_definition_id_or_name = "Key Vault Administrator"
#     principal_id               = "33333333-3333-3333-3333-333333333333"
#   }
#   "MF_MDI_CC_CORE_ACA_DDH_KEY_VAULT_ROLE_ASSGN" = {
#     role_definition_id_or_name = "Key Vault Administrator"
#     principal_id               = "33333333-3333-3333-3333-333333333333"
#   }
#   "MF_MDI_CC_CORE_KEY_VAULT_ROLE_ASSGN" = {
#     role_definition_id_or_name = "Key Vault Administrator"
#     principal_id               = "33333333-3333-3333-3333-333333333333"
#   }
# }