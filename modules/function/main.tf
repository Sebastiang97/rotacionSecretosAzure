resource "azurerm_storage_account" "func_storage" {
  name                     = "funcstoragkely"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "func_plan" {
  name                = "func-service-plan"
  location           = var.location
  resource_group_name = var.resource_group_name
  os_type            = "Linux"
  sku_name           = "B1"
}

resource "azurerm_function_app" "secret_rotation_func" {
  name                     = "secret-rotation-func"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  app_service_plan_id      = azurerm_service_plan.func_plan.id
  storage_account_name     = azurerm_storage_account.func_storage.name
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key
  os_type                  = "linux"
  version                  = "~4"

  app_settings = {
    "KEY_VAULT_URL" = var.key_vault_url
  }
}

