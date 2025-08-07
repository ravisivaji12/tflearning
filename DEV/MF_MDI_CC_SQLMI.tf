# module "sqlmi_primary" {
#   source                       = "Azure/avm-res-sql-managedinstance/azurerm"
#   version                      = "0.1.0"
#   name                         = var.sqlmi_config["primary"].name
#   location                     = var.sqlmi_config["primary"].location
#   administrator_login          = var.sqlmi_config["primary"].administrator_login
#   administrator_login_password = var.sqlmi_config["primary"].administrator_login_password
#   license_type                 = var.sqlmi_config["primary"].license_type
#   subnet_id                    = data.azurerm_subnet.all["primary.db"].id
#   sku_name                     = var.sqlmi_config["primary"].sku_name
#   vcores                       = var.sqlmi_config["primary"].vcores
#   storage_size_in_gb           = var.sqlmi_config["primary"].storage_size_in_gb
#   resource_group_name          = var.sqlmi_config["primary"].resource_group_name
#   managed_identities           = var.sqlmi_config["primary"].managed_identities != null ? var.sqlmi_config["primary"].managed_identities : null
#   # Unexpected attribute: An attribute named "backup_storage_redundancy" is not supported in this avm module. 
#   # AVM module has to downloaded and modified accordingly to configure automated backups using this AVM module.
#   # backup_storage_redundancy    = "Geo"
#   maintenance_configuration_name = "SQL_Default"
#   minimum_tls_version            = "1.2"
#   public_data_endpoint_enabled   = false

#   # failover_group is not supported in SQLMI AVM module
#   # failover_group = {
#   #   location = var.sqlmi_config.location
#   #   name = "sqlmi_failovergrp"
#   #   partner_managed_instance_id = azurerm_mssql_managed_instance.sqlmi_secondary.id
#   # }

#   depends_on = [module.resource_groups, module.vnets, module.nsgs, module.routetables, module.keyvaults]
# }