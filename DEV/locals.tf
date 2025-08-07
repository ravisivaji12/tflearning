locals {
  tag_list_1 = {
    "Application Name" = "McCain DevSecOps"
    "GL Code"          = "N/A"
    "Environment"      = "sandbox"
    "IT Owner"         = "mccain-azurecontributor@mccain.ca"
    "Onboard Date"     = "12/19/2024"
    "Modified Date"    = "N/A"
    "Organization"     = "McCain Foods Limited"
    "Business Owner"   = "trilok.tater@mccain.ca"
    "Implemented by"   = "trilok.tater@mccain.ca"
    "Resource Owner"   = "trilok.tater@mccain.ca"
    "Resource Posture" = "Private"
    "Resource Type"    = "Terraform POC"
    "Built Using"      = "Terraform"
  }
  functionapp = {
    MF-MDI-CC-GHPROD-DDDS-AFUNC = {
      name                       = "MF-MDI-CC-GHPROD-DDDS-AFUNC"
      kind                       = "functionapp"
      storage_account_name       = "mfmdiccprodghcoresa"
      storage_account_access_key = "hmxawMYxzq0GOeCv6h7QYsI64rb7PquafN4iYKBgEhuG5sczWWl0k46JtFevWPzu0XVDeZDXBLdD+ASt++JrQw=="
    }
  }
  private_dns_zones = {
    "one" = {
      domain_name         = "mccain.com"
      resource_group_name = "MF_MDIxMI_Github_PROD_RG"
      virtual_network_links = {
        "vnetlink1" = {
          vnetlinkname = "MFMDCCAppGatewayApimLink"
          vnetid       = module.avm-res-network-virtualnetwork["MF_MDI_CC_PROD_CORE-VNET"].resource_id
      } }
      # a_records = {
      #   "a_record1" = {
      #     name                = "prod-digital-manufacturing"
      #     resource_group_name = "MF_MDIxMI_Github_PROD_RG"
      #     zone_name           = "mccain.com"
      #     ttl                 = 300
      #     records             = [""]
      #   }
      # }
    }
  }

  aca_infrastructure_subnet_id = module.avm-res-network-virtualnetwork["MF_MDI_CC_PROD_CORE-VNET"].subnets["MF_MDI_CC_CAPPS-SNET"].resource_id

  container_apps = {
    "mf-mdi-cc-prod-capp-mdiauthsvc" = {
      revision_mode = "Single"

      template = {
        containers = [
          {
            name   = "mdixaiauthservice"
            image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            cpu    = 2.0
            memory = "4Gi"

            env = [{
              name  = "mdiaikeyVaultName"
              value = "MF-MDI-CORE-PRDGH-KV"
              }, {
              name  = "mdiaiUserAssignedMIClientID"
              value = "56494b1d-ec82-493d-a960-d44f58f2c144"
              },
              {
                name  = "mdiaiTenantId"
                value = "59fa7797-abec-4505-81e6-8ce092642190"
            }]
          }
        ]
      }
      managed_identities = {
        "system" = {
          system_assigned            = true
          user_assigned_resource_ids = ["/subscriptions/855f9502-3230-4377-82a2-cc5c8fa3c59d/resourceGroups/MF_MDIxMI_Github_PROD_RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MF_CC_CORE_PROD_APP_ACCESS-USER-IDENTITY"]
        }
      }
      registries = [
        {
          server   = azurerm_container_registry.this.login_server
          identity = "system"
        }
      ]
      ingress = {

        allow_insecure_connections = false
        external_enabled           = true
        target_port                = 8080
        transport                  = "http"
        traffic_weight = [{
          latest_revision = true
          percentage      = 100
        }]
      }
      role_assignments = {
        "one" = {
          principal_id               = azurerm_user_assigned_identity.MF_MDI_CC_CORE_APP_ACCESS-USER-IDENTITY.principal_id
          role_definition_id_or_name = "acrpull"
      } }

    }
    "mf-mdi-cc-prod-capp-ddh-github" = {
      revision_mode = "Single"

      template = {
        containers = [
          {
            name = "mdixaiauthservice"
            # image = "mfmdicccoreprodacrgithubaza.azurecr.io/mdixaiddh:latest"
            image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            cpu    = 2.0
            memory = "4Gi"

            env = [{
              name  = "mdiaikeyVaultName"
              value = "MF-MDI-CORE-PRDGH-KV"
              }, {
              name  = "mdiaiadappClientId"
              value = "56494b1d-ec82-493d-a960-d44f58f2c144"
              }, {
              name  = "mdiaiadappClientSecret"
              value = "Y978Q~ixFH4NsZ4KVRoFZcvXUU2hqjWAg66OfajV"
              }, {
              name  = "mdiaiTenantId"
              value = "59fa7797-abec-4505-81e6-8ce092642190"
            }]
          }
        ]
      }
      managed_identities = {
        "system" = {
          system_assigned            = true
          user_assigned_resource_ids = ["/subscriptions/855f9502-3230-4377-82a2-cc5c8fa3c59d/resourceGroups/MF_MDIxMI_Github_PROD_RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MF_CC_CORE_PROD_APP_ACCESS-USER-IDENTITY"]
        }
      }
      registries = [
        {
          server   = azurerm_container_registry.this.login_server
          identity = "system"
        }
      ]
      ingress = {

        allow_insecure_connections = false
        external_enabled           = true
        target_port                = 8080
        transport                  = "http"
        traffic_weight = [{
          latest_revision = true
          percentage      = 100
        }]
      }
      role_assignments = {
        "one" = {
          principal_id               = azurerm_user_assigned_identity.MF_MDI_CC_CORE_APP_ACCESS-USER-IDENTITY.principal_id
          role_definition_id_or_name = "acrpull"
      } }

  } }
  route_tables = {
    MF_MDI_CC_SQLMI-rt = {
      location            = "Canada Central"
      resource_group_name = "MF_MDIxMI_Github_PROD_RG"
      tags = {
        env = "prod"
      }
      subnet_resource_ids = {
        subnet1 = module.avm-res-network-virtualnetwork["MF_MDI_CC_PROD_CORE-VNET"].subnets["MF_MDI_CC_PROD_SQLMI-SNET"].resource_id,
        subnet2 = module.avm-res-network-virtualnetwork["MF_MDI_CC_PROD_CORE-VNET"].subnets["MF_MDI_CC_AFUNC-SNET"].resource_id
      }
      routes = {
        "to-internet" = {
          name           = "Internet"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "Internet"
        },
        "VDI_172.25.35.0_24" = {
          name                   = "VDI_172.25.35.0_24"
          address_prefix         = "172.25.35.0/24"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.125.251.4"
        }
        "VDI_172.16.0.0_16" = {
          name                   = "VDI_172.16.0.0_16"
          address_prefix         = "172.16.0.0/16"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.125.251.4"
        }
        "VDI_172.19.0.0_16" = {
          name                   = "VDI_172.19.0.0_16"
          address_prefix         = "172.19.0.0/16"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.125.251.4"
        }
        "VDI_172.29.0.0_16" = {
          name                   = "VDI_172.29.0.0_16"
          address_prefix         = "172.29.0.0/16"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.125.251.4"
        }

        "VnetLocal" = {
          name           = "VnetLocal"
          address_prefix = "10.125.181.192/27"
          next_hop_type  = "VnetLocal"
        }

        "AD" = {
          name           = "AD"
          address_prefix = "AzureActiveDirectory"
          next_hop_type  = "Internet"
        }

        "OneDs" = {
          name           = "OneDs"
          address_prefix = "OneDsCollector"
          next_hop_type  = "Internet"
        }

        "Storage_central" = {
          name           = "Storage_central"
          address_prefix = "Storage.canadacentral"
          next_hop_type  = "Internet"
        }

        "Storage_east" = {
          name           = "Storage_east"
          address_prefix = "Storage.canadaeast"
          next_hop_type  = "Internet"
        }

        "VDI_172.25.30.0_23" = {
          name                   = "VDI_172.25.30.0_23"
          address_prefix         = "172.25.30.0/23"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.125.251.4"
        }
      }
    }
    MF_MDI_CC_AFUNC-rt = {
      location            = "Canada Central"
      resource_group_name = "MF_MDIxMI_Github_PROD_RG"
      tags = {
        env = "prod"
      }
      routes = {
        "To_Synapse" = {
          name                   = "To_Synapse"
          address_prefix         = "172.25.246.36/32"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.125.251.4"
        },
        "VDI_172.25.0.0_16" = {
          name                   = "VDI_172.25.0.0_16"
          address_prefix         = "172.25.0.0/16"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.125.251.4"
        }
      }
    }
  }
  storage_accounts = {
    1 = {
      name = "mfmdiccprodghcoresa"
      containers = {
        mdixai = {
          name                  = "mdixai"
          container_access_type = "private"
        },
        mdiaicid = {
          name                  = "mdiaicid"
          container_access_type = "private"
        },
        mdiaiddh = {
          name                  = "mdiaiddh"
          container_access_type = "private"
        },
        mdixai-cbm = {
          name                  = "mdixai-cbm"
          container_access_type = "private"
        },
        mdi-data-archive = {
          name                  = "mdi-data-archive"
          container_access_type = "private"
        }
      }
      role_assignments = {
        DDSSRollassignment = {
          role_definition_id_or_name = "Storage Blob Data Contributor"
          principal_id               = module.container_apps["mf-mdi-cc-prod-capp-ddh-github"].resource
        },
        # ACACIDRoleassignment = {
        #   role_definition_id_or_name = "Storage Blob Data Contributor"
        #   principal_id               = module.container_apps["mf-mdi-cc-prod-capp-cid-github"].resource_id
        # },
        # webappRoleassignment = {
        #   role_definition_id_or_name       = "Storage Blob Data Contributor"
        #   principal_id                     = module.container_apps["DDSS"].identity[0].principal_id
        # },
        # DDHACARoleassignment = {
        #   role_definition_id_or_name       = "Storage Blob Data Contributor"
        #   principal_id                     = module.container_apps["DDSS"].identity[0].principal_id
        # }
      }
    }
  }
}
