locals {
  default_name_pattern           = lower("${var.metadata.org_code}-${replace(var.metadata.solution, " ", "")}${lower(var.metadata.application) != lower(var.metadata.solution) ? "${replace(var.metadata.application, " ", "")}" : ""}${length(var.sub_component) > 0 ? "-${replace(var.sub_component, " ", "")}" : ""}${var.is_foundational_resource == true ? "-foundation" : ""}${length(var.suffix) > 0 ? "-${var.suffix}" : ""}-${var.metadata.env_code}-${var.metadata.region_code}")
  default_name_pattern_old       = lower("${var.metadata.org_code}-${var.metadata.region_code}-${replace(var.metadata.solution, " ", "")}${lower(var.metadata.application) != lower(var.metadata.solution) ? "${replace(var.metadata.application, " ", "")}" : ""}${length(var.sub_component) > 0 ? "-${replace(var.sub_component, " ", "")}" : ""}${var.is_foundational_resource == true ? "-foundation" : ""}${length(var.suffix) > 0 ? "-${var.suffix}" : ""}-${var.metadata.env_code}")
  resource_group                 = "${local.default_name_pattern}-rg"
  log_analytics_workspace        = "${local.default_name_pattern}-la"
  storage_account                = "${substr(replace(local.default_name_pattern, "-", ""), 0, 22)}st"
  virtual_network                = "${local.default_name_pattern}-vnet"
  subnet                         = "${local.default_name_pattern}-snet"
  user_assigned_managed_identity = "${local.default_name_pattern}-mi"
  network_security_group         = "${local.default_name_pattern}-nsg"
  route_table                    = "${local.default_name_pattern}-udr"
  virtual_machine                = "${local.default_name_pattern}-vm"
  image_gallery                  = replace("${local.default_name_pattern}-gal", "-", "_")
  key_vault                      = "${substr(local.default_name_pattern, 0, 21)}-kv"
  private_endpoint = {
    storage_account = {
      blob  = "${local.storage_account}-blob-pe"
      table = "${local.storage_account}-table-pe"
      queue = "${local.storage_account}-queue-pe"
      file  = "${local.storage_account}-file-pe"
      dfs   = "${local.storage_account}-dfs-pe"
      web   = "${local.storage_account}-web-pe"
    }
    key_vault = {
      vault = "${local.key_vault}-vault-pe"
    }
  }
  recovery_services_vault        = "${local.default_name_pattern}-rsv"
  recovery_services_vault_policy = "${local.default_name_pattern}-policy"
  application_security_group     = "${local.default_name_pattern}-asg"
  application_secuiry_group_old  = "${local.default_name_pattern_old}-asg"
  app_registration               = "${local.default_name_pattern_old}-spn"
}