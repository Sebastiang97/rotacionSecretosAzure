terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.7.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "0bea0a37-89cb-43fb-976f-0d8a3d8b1e4b"
}

module "mod_resource_group" {
  source = "./modules/resource_group"
}

variable "tenant_id" {
  type = string
}

resource "azurerm_storage_account" "storage" {
  name                     = "storagekvrotationkely" # Nombre único requerido
  resource_group_name      = module.mod_resource_group.out_rg_name
  location                 = module.mod_resource_group.out_rg_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "kvrotationekely"
  location                    = module.mod_resource_group.out_rg_location
  resource_group_name         = module.mod_resource_group.out_rg_name
  sku_name                    = "standard"
  tenant_id                   = var.tenant_id
  enable_rbac_authorization   = true
}

# Evento de rotación de secretos en Key Vault
resource "azurerm_eventgrid_system_topic" "eventgrid" {
  name                   = "kv-rotation-events-kely"
  resource_group_name    = module.mod_resource_group.out_rg_name
  location               = module.mod_resource_group.out_rg_location
  source_arm_resource_id = azurerm_key_vault.keyvault.id
  topic_type             = "Microsoft.KeyVault.Vaults"
}

resource "azurerm_eventgrid_event_subscription" "rotation_event" {
  name                  = "kv-rotation-subscription-kely"
  scope                 = azurerm_eventgrid_system_topic.eventgrid.id
  event_delivery_schema = "EventGridSchema"

  webhook_endpoint {
    url = azurerm_function_app.function.default_hostname
  }
}

resource "azurerm_service_plan" "service_plan" {
  name                = "serviceplan-kv-rotation-kely"
  location            = module.mod_resource_group.out_rg_location
  resource_group_name = module.mod_resource_group.out_rg_name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_function_app" "function" {
  name                       = "function-kv-rotation-kely"
  location                   = module.mod_resource_group.out_rg_location
  resource_group_name        = module.mod_resource_group.out_rg_name
  service_plan_id            = azurerm_service_plan.service_plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  os_type                    = "linux"
  app_settings = {
    "KEYVAULT_NAME" = azurerm_key_vault.keyvault.name
  }

  identity {
    type = "SystemAssigned"
  }
}

# Asignación de permisos a la Azure Function para acceder a Key Vault
resource "azurerm_role_assignment" "function_kv_access" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets Officer kely"
  principal_id         = azurerm_function_app.function.identity[0].principal_id
}

# Grupo de acción para notificaciones
resource "azurerm_monitor_action_group" "notification" {
  name                = "rotation-notify-kely"
  resource_group_name = module.mod_resource_group.out_rg_name
  short_name          = "notify"
  email_receiver {
    name          = "kely"
    email_address = "kelyyinethdp28@gmail.com"
  }
}
