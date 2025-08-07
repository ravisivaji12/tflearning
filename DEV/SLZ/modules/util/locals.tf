locals {
  diagnostic_settings_helper = {
    log_analytics_workspace = {
      log_categories      = ["Audit", "SummaryLogs"]
      log_category_groups = ["audit", "allLogs"]
      metric_categories   = ["AllMetrics"]
    }
    storage_account = {
      log_categories      = []
      log_category_groups = []
      metric_categories   = ["Capacity", "Transaction"]
    }
    storage_account_blob = {
      log_categories      = ["StorageDelete", "StorageWrite", "StorageRead"]
      log_category_groups = ["audit", "allLogs"]
      metric_categories   = ["Capacity", "Transaction"]
    }
    storage_account_file = {
      log_categories      = ["StorageDelete", "StorageWrite", "StorageRead"]
      log_category_groups = ["audit", "allLogs"]
      metric_categories   = ["Capacity", "Transaction"]
    }
  }
}