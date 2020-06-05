data "azurerm_resource_group" "base" {
  name = var.resource_group_name
}

data "azurerm_client_config" "user" {
}
