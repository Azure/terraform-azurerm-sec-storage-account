provider "azurerm" {
  version = "~>2.0"
  features {}
}

module "naming" {
  source        = "git::https://github.com/Azure/terraform-azurerm-naming"
  unique-length = 14
}

resource "azurerm_storage_account" "storage_account" {
  name                      = length(var.storage_account_name) == 0 ? module.naming.storage_account.name_unique : var.storage_account_name
  resource_group_name       = data.azurerm_resource_group.base.name
  location                  = data.azurerm_resource_group.base.location
  account_tier              = var.storage_account_tier
  account_replication_type  = var.storage_account_replication_type
  enable_https_traffic_only = true
  is_hns_enabled            = var.enable_data_lake_filesystem
  account_kind              = "StorageV2"
  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.allowed_ip_ranges
    bypass                     = var.bypass_internal_network_rules ? ["Logging", "Metrics", "AzureServices"] : ["None"]
    virtual_network_subnet_ids = var.permitted_virtual_network_subnet_ids
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_advanced_threat_protection" "storage_atp" {
  target_resource_id = azurerm_storage_account.storage_account.id
  enabled            = true
}

resource "azurerm_role_assignment" "role_assignment" {
  scope                = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.user.object_id
}

resource "time_sleep" "role_assignment_wait" {
  depends_on = [
    azurerm_role_assignment.role_assignment
  ]

  create_duration = "180s"
  count           = var.enable_data_lake_filesystem ? 1 : 0 
}

resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_gen2_filesystem" {
  name               = length(var.data_lake_filesystem_name) == 0 ? module.naming.storage_data_lake_gen2_filesystem.name_unique : var.data_lake_filesystem_name
  storage_account_id = azurerm_storage_account.storage_account.id
  depends_on         = [time_sleep.role_assignment_wait]
  count              = var.enable_data_lake_filesystem ? 1 : 0
}
