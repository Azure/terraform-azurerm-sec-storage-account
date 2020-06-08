provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  unique_name_stub = substr(module.naming.unique-seed, 0, 5)
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
}
resource "azurerm_resource_group" "test_group" {
  name     = "${module.naming.resource_group.slug}-${module.naming.storage_account.slug}-max-test-${local.unique_name_stub}"
  location = "uksouth"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "storage-test-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test_group.location
  resource_group_name = azurerm_resource_group.test_group.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "storage-test-subnet"
  resource_group_name  = azurerm_resource_group.test_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.2.0/24"
  service_endpoints    = ["Microsoft.Storage"]
}

module "terraform-azurerm-storage" {
  source                               = "../../"
  resource_group_name                  = azurerm_resource_group.test_group.name
  storage_account_name                 = "testsafull"
  storage_account_tier                 = "Standard"
  storage_account_replication_type     = "LRS"
  allowed_ip_ranges                    = [data.external.test_client_ip.result.ip]
  permitted_virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  bypass_internal_network_rules        = true
  #enable_data_lake_filesystem          = true
  #data_lake_filesystem_name            = module.naming.data_lake_file_system.name_unique
}
