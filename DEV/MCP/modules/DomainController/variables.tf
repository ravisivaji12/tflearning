variable "cc_resource_group" {
  type = object({
    name     = string
    location = string
    tags     = optional(map(string), {})
    lock = optional(object({
      level = string
      notes = optional(string)
    }), null)
  })
  description = "Resource Group"
}

variable "enable_telemetry" {
  type        = bool
  description = "Flag for enabling telemetry for the AVM Modules"
  default     = false
}

variable "cc_vnet" {
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    address_space       = list(string)
    subnets = map(object({
      name                              = string
      address_prefixes                  = list(string)
      service_endpoints                 = list(string)
      default_outbound_access_enabled   = bool
      private_endpoint_network_policies = string
      delegation = list(object({
        name = string
        service_delegation = object({
          name = string
        actions = list(string) })
      }))
      network_security_group = object({ id = string })
      route_table            = object({ id = string })
    }))
  })
  description = "Virtual network"
}

variable "nsgs" {
  description = "Map of NSGs to create"
  type = map(object({
    location            = string
    resource_group_name = string
    security_rules = map(object({
      access                                     = string
      description                                = optional(string)
      destination_address_prefix                 = optional(string)
      destination_address_prefixes               = optional(set(string))
      destination_application_security_group_ids = optional(set(string))
      destination_port_range                     = optional(string)
      destination_port_ranges                    = optional(set(string))
      direction                                  = string
      name                                       = string
      priority                                   = number
      protocol                                   = string
      source_address_prefix                      = optional(string)
      source_address_prefixes                    = optional(set(string))
      source_application_security_group_ids      = optional(set(string))
      source_port_range                          = optional(string)
      source_port_ranges                         = optional(set(string))
      timeouts = optional(object({
        create = optional(string)
        delete = optional(string)
        read   = optional(string)
        update = optional(string)
      }))
    }))
  }))
}

variable "route_tables" {
  description = "Map of route table configurations"
  type = map(object({
    location            = string
    resource_group_name = string
    tags                = optional(map(string), {})
    subnet_resource_ids = optional(map(string))
    routes = map(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    }))
  }))
}

variable "user_assigned_identities" {
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
  }))
}

variable "keyvaults" {
  description = "Map of Key Vault configurations"
  type = map(object({
    location                               = string
    name                                   = string
    resource_group_name                    = string
    enabled_for_disk_encryption            = bool
    keys                                   = map(any)
    network_acls                           = map(string)
    wait_for_rbac_before_key_operations    = map(string)
    wait_for_rbac_before_secret_operations = map(string)
  }))
}

variable "disk_encryption_sets" {
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    key_vault_key_name  = string
    identity_name       = string
  })
}

variable "virtual_machine_configs" {
  type = map(object({
    name                               = string
    location                           = string
    resource_group_name                = string
    zone                               = string
    encryption_at_host_enabled         = bool
    account_credentials_adcredusername = string
    generate_admin_password_or_ssh_key = bool
    ddms_name                          = string
    ddms_storage_account_type          = string
    ddms_lun                           = number
    ddms_caching                       = string
    ddms_disk_size_gb                  = number
    os_type                            = string
    sku_size                           = string
    computer_name                      = string
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    extensions = map(object({
      name                       = string
      publisher                  = string
      type                       = string
      type_handler_version       = string
      auto_upgrade_minor_version = bool
      settings                   = optional(map(any))
      protected_settings         = optional(map(any))
    }))
    network_interfaces = map(object({
      name                = string
      location            = string
      resource_group_name = string
      enable_telemetry    = optional(bool, false)
      ip_configurations = map(object({
        name                          = string
        private_ip_subnet_resource_id = string
        private_ip_address_allocation = string
        private_ip_address            = string
      }))
      network_security_group_ids = list(string)
    }))
  }))
}

variable "recovery_vault_config" {
  type = object({
    name                                           = string
    location                                       = string
    resource_group_name                            = string
    cross_region_restore_enabled                   = bool
    alerts_for_all_job_failures_enabled            = bool
    alerts_for_critical_operation_failures_enabled = bool
    classic_vmware_replication_enabled             = bool
    public_network_access_enabled                  = bool
    storage_mode_type                              = string
    sku                                            = string
    managed_identities = object({
      system_assigned            = bool
      user_assigned_resource_ids = list(string)
    })
    tags                     = map(string)
    workload_backup_policy   = any
    vm_backup_policy         = any
    file_share_backup_policy = any
  })
}

variable "log_analytics_workspace" {
  type = object({
    name                = string
    location            = string
    resource_group_name = string
  })
}

variable "storage_account" {
  type = object({
    name                              = string
    account_replication_type          = string
    location                          = string
    resource_group_name               = string
    infrastructure_encryption_enabled = bool
    container_name                    = string
    container_access_type             = string
  })
}

variable "domain_controller_default_nsg_rules" {
  description = "Default rules to be applied to domain controller NSG"
  type = map(object({
    access                                     = string
    description                                = optional(string)
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(set(string))
    destination_application_security_group_ids = optional(set(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(set(string))
    direction                                  = string
    name                                       = string
    priority                                   = number
    protocol                                   = string
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(set(string))
    source_application_security_group_ids      = optional(set(string))
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(set(string))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default = {
    "AllowRDP" = {
      name                       = "AllowRDP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "tcp_53_dc_inbound" = {
      name                       = "AD_53_DNS_TCP_-_DC_Inbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "53"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "udp_53_dc_inbound" = {
      name                       = "AD_53_DNS_UDP_-_DC_Inbound"
      priority                   = 111
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "53"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "tcp_88_dc_inbound" = {
      name                       = "AD_88_Kerberos_TCP_-_DC_Inbound"
      priority                   = 112
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "88"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "udp_88_dc_inbound" = {
      name                       = "AD_88_Kerberos_UDP_-_DC_Inbound"
      priority                   = 113
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "88"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "udp_123_dc_inbound" = {
      name                       = "AD_123_W32Time_UDP_-_DC_Inbound"
      priority                   = 114
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "123"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "tcp_135_dc_inbound" = {
      name                       = "AD_135_RPC_TCP_-_DC_Inbound"
      priority                   = 115
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "135"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "udp_137-138_dc_inbound" = {
      name                       = "AD_137-138_NetLogon_UDP_-_DC_Inbound"
      priority                   = 116
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "137-138"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "tcp_139_dc_inbound" = {
      name                       = "AD_139_NetLogon_TCP_-_DC_Inbound"
      priority                   = 117
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "139"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "tcp_389_dc_inbound" = {
      name                       = "AD_389_LDAP_TCP_-_DC_Inbound"
      priority                   = 118
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "389"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "udp_389_dc_inbound" = {
      name                       = "AD_389_LDAP_UDP_-_DC_Inbound"
      priority                   = 119
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "389"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "tcp_445_dc_inbound" = {
      name                       = "AD_445_SMB_TCP_-_DC_Inbound"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "445"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "tcp_464_dc_inbound" = {
      name                       = "AD_464_Kerberos_Authentication_TCP_-_DC_Inbound"
      priority                   = 121
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "464"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "udp_464_dc_inbound" = {
      name                       = "AD_464_Kerberos_Authentication_UDP_-_DC_Inbound"
      priority                   = 122
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "464"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "tcp_636_dc_inbound" = {
      name                       = "AD_636_LDAP_SSL_TCP_-_DC_Inbound"
      priority                   = 123
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "636"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "tcp_3268-3269_dc_inbound" = {
      name                       = "AD_3268-3269_LDAP_GC_TCP_-_DC_Inbound"
      priority                   = 124
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3268-3269"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "tcp_49152-65535_dc_inbound" = {
      name                       = "AD_49152-65535_TCP_-_DC_Inbound"
      priority                   = 125
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "49152-65535"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "udp_49152-65535_dc_inbound" = {
      name                       = "AD_49152-65535_UDP_-_DC_Inbound"
      priority                   = 126
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "49152-65535"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "icmp_dc_inbound" = {
      name                       = "AD_Icmp_to_DC_Inbound"
      priority                   = 127
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Icmp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefixes    = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
      destination_address_prefix = "VirtualNetwork"
    },
    "tcp_53_dc_outbound" = {
      name                         = "AD_53_DNS_TCP_-_DC_Outbound"
      priority                     = 130
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "53"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "udp_53_dc_outbound" = {
      name                         = "AD_53_DNS_UDP_-_DC_Outbound"
      priority                     = 131
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Udp"
      source_port_range            = "*"
      destination_port_range       = "53"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "tcp_88_dc_outbound" = {
      name                         = "AD_88_Kerberos_TCP_-_DC_Outbound"
      priority                     = 132
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "88"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "udp_88_dc_outbound" = {
      name                         = "AD_88_Kerberos_UDP_-_DC_Outbound"
      priority                     = 133
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Udp"
      source_port_range            = "*"
      destination_port_range       = "88"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "udp_123_dc_outbound" = {
      name                         = "AD_123_W32Time_UDP_-_DC_Outbound"
      priority                     = 134
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Udp"
      source_port_range            = "*"
      destination_port_range       = "123"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "tcp_135_dc_outbound" = {
      name                         = "AD_135_RPC_TCP_-_DC_Outbound"
      priority                     = 135
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "135"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "udp_137-138_dc_outbound" = {
      name                         = "AD_137-138_NetLogon_UDP_-_DC_Outbound"
      priority                     = 136
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Udp"
      source_port_range            = "*"
      destination_port_range       = "137-138"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "tcp_139_dc_outbound" = {
      name                         = "AD_139_NetLogon_TCP_-_DC_Outbound"
      priority                     = 137
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Udp"
      source_port_range            = "*"
      destination_port_range       = "139"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "tcp_389_dc_outbound" = {
      name                         = "AD_389_LDAP_TCP_-_DC_Outbound"
      priority                     = 138
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "389"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "udp_389_dc_outbound" = {
      name                         = "AD_389_LDAP_UDP_-_DC_Outbound"
      priority                     = 139
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Udp"
      source_port_range            = "*"
      destination_port_range       = "389"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "tcp_445_dc_outbound" = {
      name                         = "AD_445_SMB_TCP_-_DC_Outbound"
      priority                     = 141
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "445"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "tcp_464_dc_outbound" = {
      name                         = "AD_464_Kerberos_Authentication_TCP_-_DC_Outbound"
      priority                     = 142
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "464"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "udp_464_dc_outbound" = {
      name                         = "AD_464_Kerberos_Authentication_UDP_-_DC_Outbound"
      priority                     = 143
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Udp"
      source_port_range            = "*"
      destination_port_range       = "464"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    },
    "tcp_636_dc_outbound" = {
      name                         = "AD_636_LDAP_SSL_TCP_-_DC_Outbound"
      priority                     = 144
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "636"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    }
    "tcp_636_dc_outbound" = {
      name                         = "AD_DS_Web_Services"
      priority                     = 145
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "9389"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    }
    "tcp_636_dc_outbound" = {
      name                         = "AD_DS_Web_Services"
      priority                     = 146
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      source_port_range            = "*"
      destination_port_range       = "9389"
      source_address_prefix        = "VirtualNetwork"
      destination_address_prefixes = ["172.16.0.0/12", "10.122.0.0/15", "10.124.0.0/15"]
    }
  }
}

variable "default_udr_routes" {
  description = "Default UDR routes to be applied to domain controller route tables"
  type = map(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {
    "internet-to-Firewall" = {
      name           = "Internet"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "VirtualAppliance"
      # TODO: Update this to the IP of Canada East firewall post testing
      next_hop_in_ip_address = "10.125.251.4"
    }
  }
}

variable "private_endpoint_subnet_key" {
  type        = string
  description = "Key for the private endpoint subnet in the domain controller VNet"
}

variable "NIC_subnet_key" {
  type        = string
  description = "Key for the NIC subnet in the domain controller VNet"
}

variable "identity_key" {
  type        = string
  description = "Key for the user assigned identity to be used for CMK encryption"
}

variable "key_vault_key" {
  type = string
}

variable "disk_encryption_set_config_key" {
  type = string
}

variable "key_vault_private_dns_zone_resource_id" {
  type        = string
  description = "Resource ID of the Key Vault private DNS zone"
}

variable "storage_account_private_dns_zone_resource_id" {
  type        = string
  description = "Resource ID of the Storage Account private DNS zone"
}

variable "encryption_key_name" {
  type        = string
  description = "Name of the encryption key to be used for disk encryption"
}

variable "hub_vnet_name" {
  type        = string
  description = "Name of the hub virtual network"
}

variable "hub_vnet_id" {
  type        = string
  description = "Resource ID of the hub virtual network"
}

variable "vm_login_username" {
  type        = string
  description = "Default VM admin username for domain controllers"
}

variable "cfg_tenant_id" {
  type        = string
  default     = "59fa7797-abec-4505-81e6-8ce092642190"
  description = "Tenant ID for the configuration"
}

variable "cfg_core_infrastructure_subscription_id" {
  type        = string
  default     = "65763622-4bd1-45e6-82fc-2f11e3663439"
  description = "Subscription ID for the core infrastructure"
}

variable "enable_peering" {
  type        = bool
  default     = true
  description = "Flag to enable peering between the domain controller VNet and the hub VNet"
}

variable "backup_policy_identifier" {
  type        = string
  description = "The value of key used for the backup policy so it can be referenced in the code to fetch its id"
}