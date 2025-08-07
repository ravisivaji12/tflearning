locals {
  domain_controller_parameters = {
    cc_resource_group = {
      name     = module.metadata-domain_controller.resource_names.resource_group
      location = module.metadata-domain_controller.metadata_object.region
      tags     = module.metadata-domain_controller.tags
      lock = {
        level = "CanNotDelete"
        notes = "Lock to prevent deletion of domain controller components"
      }
    }
    cc_vnet = {
      name                = module.metadata-domain_controller.resource_names.virtual_network
      resource_group_name = module.metadata-domain_controller.resource_names.resource_group
      location            = module.metadata-domain_controller.metadata_object.region
      address_space       = [var.domain_controller_vnet_config.vnet_address_space]
      subnets = {
        for subnet_key, subnet_info in var.domain_controller_vnet_config.subnets : subnet_key => {
          name                              = module.metadata-domain_controller_subnets[subnet_key].resource_names.subnet
          address_prefixes                  = [subnet_info.address_space]
          service_endpoints                 = []
          default_outbound_access_enabled   = true
          delegation                        = []
          private_endpoint_network_policies = "Disabled"
          tags                              = module.metadata-domain_controller.tags
          nsg_name                          = module.metadata-domain_controller_subnets[subnet_key].resource_names.network_security_group
          network_security_group = {
            id = "/subscriptions/${var.cfg_core_infrastructure_subscription_id}/resourceGroups/${module.metadata-domain_controller.resource_names.resource_group}/providers/Microsoft.Network/networkSecurityGroups/${module.metadata-domain_controller_subnets[subnet_key].resource_names.network_security_group}"
          }
          route_table = {
            id = "/subscriptions/${var.cfg_core_infrastructure_subscription_id}/resourceGroups/${module.metadata-domain_controller.resource_names.resource_group}/providers/Microsoft.Network/routeTables/${module.metadata-domain_controller.resource_names.route_table}"
          }
        }
      }
    }
    nsgs = {
      for subnet_key, subnet_info in var.domain_controller_vnet_config.subnets : "${module.metadata-domain_controller_subnets[subnet_key].resource_names.network_security_group}" => {
        location            = module.metadata-domain_controller.metadata_object.region
        resource_group_name = module.metadata-domain_controller.resource_names.resource_group
        security_rules = subnet_key == "app" ? {} : {
          "AllowHTTPS" = {
            name                       = "AllowHTTPS"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "443"
            source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
            destination_address_prefix = "VirtualNetwork"
          }
        }
      }
    }
    route_tables = {
      "${module.metadata-domain_controller.resource_names.route_table}" = {
        location            = module.metadata-domain_controller.metadata_object.region
        resource_group_name = module.metadata-domain_controller.resource_names.resource_group
        tags                = module.metadata-domain_controller.tags
        subnet_resource_ids = {
          for subnet_key, subnet_info in var.domain_controller_vnet_config.subnets : subnet_key => "/subscriptions/${var.cfg_core_infrastructure_subscription_id}/resourceGroups/${module.metadata-domain_controller.resource_names.resource_group}/providers/Microsoft.Network/virtualNetworks/${module.metadata-domain_controller.resource_names.virtual_network}/subnets/${module.metadata-domain_controller_subnets[subnet_key].resource_names.subnet}"
        }
        routes = {}
      }
    }
    user_assigned_identities = {
      mf-core-dc-uaid = {
        name                = module.metadata-domain_controller.resource_names.user_assigned_managed_identity
        location            = module.metadata-domain_controller.metadata_object.region
        resource_group_name = module.metadata-domain_controller.resource_names.resource_group
      }
    }
    keyvaults = {
      kv1 = {
        location                    = module.metadata-domain_controller.metadata_object.region
        name                        = module.metadata-domain_controller.resource_names.key_vault
        resource_group_name         = module.metadata-domain_controller.resource_names.resource_group
        enabled_for_disk_encryption = true
        keys = {
          des_key = {
            name     = "disk-key"
            key_type = "RSA"
            key_size = 2048
            key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
          }
        }
        network_acls = {
          default_action = "Allow"
          bypass         = "AzureServices"
        }
        wait_for_rbac_before_key_operations = {
          create = "60s"
        }
        wait_for_rbac_before_secret_operations = {
          create = "60s"
        }
      }
    }
    disk_encryption_sets = {
      name                = module.metadata-domain_controller-vm["1"].resource_names.disk_encryption_set
      location            = module.metadata-domain_controller.metadata_object.region
      resource_group_name = module.metadata-domain_controller.resource_names.resource_group
      key_vault_key_name  = "${module.metadata-domain_controller.resource_names.virtual_machine}-disk-key"
      identity_name       = module.metadata-domain_controller.resource_names.user_assigned_managed_identity
    }
    virtual_machine_configs = {
      "dc1" = {
        name                               = module.metadata-domain_controller-vm["1"].resource_names.virtual_machine
        location                           = module.metadata-domain_controller.metadata_object.region
        resource_group_name                = module.metadata-domain_controller.resource_names.resource_group
        zone                               = lower(module.metadata-domain_controller.metadata_object.region) == "canadaeast" ? null : "1"
        encryption_at_host_enabled         = true
        account_credentials_adcredusername = var.default_vm_username
        generate_admin_password_or_ssh_key = false
        ddms_name                          = module.metadata-domain_controller-vm["1"].resource_names.managed_disk_data
        ddms_storage_account_type          = "Premium_LRS"
        ddms_lun                           = 10
        ddms_caching                       = "ReadWrite"
        ddms_disk_size_gb                  = 128
        os_type                            = "Windows"
        sku_size                           = "Standard_D4s_v3"
        computer_name                      = "${var.default_domain_controller_hostname}${var.domain_controller_suffix_1}"
        source_image_reference = {
          publisher = "MicrosoftWindowsServer"
          offer     = "WindowsServer"
          sku       = "2022-datacenter-azure-edition"
          version   = "latest"
        }
        extensions = {
          NetworkWatcherAgent = {
            name                       = "AzureNetworkWatcherExtension"
            publisher                  = "Microsoft.Azure.NetworkWatcher"
            type                       = "NetworkWatcherAgentWindows"
            type_handler_version       = "1.4"
            auto_upgrade_minor_version = true
          }
          VMAccessAgent = {
            name                       = "VMAccessAgent"
            publisher                  = "Microsoft.Compute"
            type                       = "VMAccessAgent"
            type_handler_version       = "2.4"
            auto_upgrade_minor_version = true
            settings = {
              userName = var.default_vm_username
            }
            protected_settings = {
              password = var.domain_controller_password
            }
          }
          # DefenderForEndpoint = {
          #   name                       = "DefenderForEndpoint"
          #   publisher                  = "Microsoft.Azure.AzureDefenderForServers"
          #   type                       = "MDE.Windows"
          #   type_handler_version       = "1.0"
          #   auto_upgrade_minor_version = true
          # }
        }
        network_interfaces = {
          nic1 = {
            name                = module.metadata-domain_controller-vm["1"].resource_names.network_interface
            location            = module.metadata-domain_controller.metadata_object.region
            resource_group_name = module.metadata-domain_controller.resource_names.resource_group
            enable_telemetry    = false
            ip_configurations = {
              ipconfig1 = {
                name = "${module.metadata-domain_controller-vm["1"].resource_names.network_interface}-ipconfig"
                # Remove this hardcoding after fixing the id generation
                private_ip_subnet_resource_id = "/subscriptions/${var.cfg_core_infrastructure_subscription_id}/resourceGroups/${module.metadata-domain_controller.resource_names.resource_group}/providers/Microsoft.Network/virtualNetworks/${module.metadata-domain_controller.resource_names.virtual_network}/subnets/${module.metadata-domain_controller_subnets[var.NIC_subnet_key].resource_names.subnet}"
                #private_ip_subnet_resource_id = "/subscriptions/${var.cfg_core_infrastructure_subscription_id}/resourceGroups/${module.metadata-domain_controller.resource_names.resource_group}/providers/Microsoft.Network/virtualNetworks/${module.metadata-domain_controller.resource_names.virtual_network}/subnets/${module.metadata-domain_controller_subnets[var.NIC_subnet_key].resource_names.subnet}"
                private_ip_address_allocation = "Static"
                private_ip_address            = var.domain_controller_private_ip_1
              }
            }
            network_security_group_ids = []
            tags                       = module.metadata-domain_controller.tags
          }
        }
      },
      "dc2" = {
        name                               = module.metadata-domain_controller-vm["2"].resource_names.virtual_machine
        location                           = module.metadata-domain_controller.metadata_object.region
        resource_group_name                = module.metadata-domain_controller.resource_names.resource_group
        zone                               = lower(module.metadata-domain_controller.metadata_object.region) == "canadaeast" ? null : "2"
        encryption_at_host_enabled         = true
        account_credentials_adcredusername = var.default_vm_username
        generate_admin_password_or_ssh_key = false
        ddms_name                          = module.metadata-domain_controller-vm["2"].resource_names.managed_disk_data
        ddms_storage_account_type          = "Premium_LRS"
        ddms_lun                           = 10
        ddms_caching                       = "ReadWrite"
        ddms_disk_size_gb                  = 128
        os_type                            = "Windows"
        sku_size                           = "Standard_D4s_v3"
        computer_name                      = "${var.default_domain_controller_hostname}${var.domain_controller_suffix_2}"
        source_image_reference = {
          publisher = "MicrosoftWindowsServer"
          offer     = "WindowsServer"
          sku       = "2025-datacenter-azure-edition"
          version   = "latest"
        }
        extensions = {
          # AdminCenter = {
          #   name                       = "AdminCenter"
          #   publisher                  = "Microsoft.AdminCenter"
          #   type                       = "AdminCenter"
          #   type_handler_version       = "1.0"
          #   auto_upgrade_minor_version = true
          # }
          NetworkWatcherAgent = {
            name                       = "NetworkWatcherAgentWindows"
            publisher                  = "Microsoft.Azure.NetworkWatcher"
            type                       = "NetworkWatcherAgentWindows"
            type_handler_version       = "1.4"
            auto_upgrade_minor_version = true
          }
          VMAccessAgent = {
            name                       = "VMAccessAgent"
            publisher                  = "Microsoft.Compute"
            type                       = "VMAccessAgent"
            type_handler_version       = "2.4"
            auto_upgrade_minor_version = true
            settings = {
              userName = var.default_vm_username
            }
            protected_settings = {
              password = var.domain_controller_password
            }
          }
          # DefenderForEndpoint = {
          #   name                       = "DefenderForEndpoint"
          #   publisher                  = "Microsoft.Azure.AzureDefenderForServers"
          #   type                       = "MDE.Windows"
          #   type_handler_version       = "1.0"
          #   auto_upgrade_minor_version = true
          # }
        }
        network_interfaces = {
          nic1 = {
            name                = module.metadata-domain_controller-vm["2"].resource_names.network_interface
            location            = module.metadata-domain_controller.metadata_object.region
            resource_group_name = module.metadata-domain_controller.resource_names.resource_group
            enable_telemetry    = false
            ip_configurations = {
              ipconfig1 = {
                name = "${module.metadata-domain_controller-vm["2"].resource_names.network_interface}-ipconfig"
                # Remove this hardcoding After Fixing the ID generation issue
                private_ip_subnet_resource_id = "/subscriptions/${var.cfg_core_infrastructure_subscription_id}/resourceGroups/${module.metadata-domain_controller.resource_names.resource_group}/providers/Microsoft.Network/virtualNetworks/${module.metadata-domain_controller.resource_names.virtual_network}/subnets/${module.metadata-domain_controller_subnets[var.NIC_subnet_key].resource_names.subnet}"
                #private_ip_subnet_resource_id = "/subscriptions/${var.cfg_core_infrastructure_subscription_id}/resourceGroups/${module.metadata-domain_controller.resource_names.resource_group}/providers/Microsoft.Network/virtualNetworks/${module.metadata-domain_controller.resource_names.virtual_network}/subnets/${module.metadata-domain_controller_subnets[var.NIC_subnet_key].resource_names.subnet}"
                private_ip_address_allocation = "Static"
                private_ip_address            = var.domain_controller_private_ip_2
              }
            }
            network_security_group_ids = []
            tags                       = module.metadata-domain_controller.tags
          }
        }
      }
    }
    recovery_vault_config = {
      name                                           = module.metadata-domain_controller.resource_names.recovery_services_vault
      location                                       = module.metadata-domain_controller.metadata_object.region
      resource_group_name                            = module.metadata-domain_controller.resource_names.resource_group
      cross_region_restore_enabled                   = false
      alerts_for_all_job_failures_enabled            = true
      alerts_for_critical_operation_failures_enabled = true
      classic_vmware_replication_enabled             = false
      public_network_access_enabled                  = true
      storage_mode_type                              = "GeoRedundant"
      sku                                            = "RS0"
      managed_identities = {
        system_assigned            = true
        user_assigned_resource_ids = ["/subscriptions/${var.cfg_core_infrastructure_subscription_id}/resourceGroups/${module.metadata-domain_controller.resource_names.resource_group}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${module.metadata-domain_controller.resource_names.user_assigned_managed_identity}"]
      }
      tags                   = module.metadata-domain_controller.tags
      workload_backup_policy = {}

      vm_backup_policy = {
        "${module.metadata-domain_controller.resource_names.recovery_services_vault_policy}" = {
          name        = module.metadata-domain_controller.resource_names.recovery_services_vault_policy
          timezone    = "Eastern Standard Time"
          policy_type = "V1"
          frequency   = "Daily"
          time        = "23:00"
          backup = {
            frequency = "Daily"
            time      = "23:00"
          }
          retention_daily = {
            count = 8
          }
          retention_weekly = {
            count    = 5
            weekdays = ["Sunday"]
          }
          retention_monthly = {
            count             = 2
            weekdays          = ["Sunday"]
            weeks             = ["Last"]
            include_last_days = false
          }
          retention_yearly = {
            count             = 1
            weekdays          = ["Sunday"]
            weeks             = ["Last"]
            months            = ["June"]
            include_last_days = false
          }
        }
      }

      file_share_backup_policy = {}
    }
    log_analytics_workspace = {
      name                = module.metadata-domain_controller.resource_names.log_analytics_workspace
      location            = module.metadata-domain_controller.metadata_object.region
      resource_group_name = module.metadata-domain_controller.resource_names.resource_group
      tags                = module.metadata-domain_controller.tags
    }
    storage_account = {
      name                              = module.metadata-domain_controller.resource_names.storage_account
      account_replication_type          = lower(module.metadata-domain_controller.metadata_object.region) == "canadaeast" ? "LRS" : "GRS"
      location                          = module.metadata-domain_controller.metadata_object.region
      resource_group_name               = module.metadata-domain_controller.resource_names.resource_group
      infrastructure_encryption_enabled = true
      container_name                    = module.metadata-domain_controller-vm["1"].resource_names.virtual_machine
      container_access_type             = "private"
      tags                              = module.metadata-domain_controller.tags
    }
    NIC_subnet_key              = "app"
    private_endpoint_subnet_key = "private_endpoints"
  }
}