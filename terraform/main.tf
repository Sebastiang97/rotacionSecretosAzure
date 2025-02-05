/*------------------
Client Config Data
------------------*/
data "azurerm_client_config" "client_config" {
}

/*--------------
Resource Group
--------------*/
# resource "azurerm_resource_group" "rg" {
#   name     = "${local.app}-rg-${var.environment}"
#   location = var.resource_group_location
#   tags     = local.tags
# }
module "mod_resource_group" {
  source = "./modules/resource_group"
}
/*--------------
Storage Account
--------------*/
resource "azurerm_storage_account" "st" {
  name                     = replace("${local.app}st${var.environment}", "/[[:^alnum:]]/", "")
  resource_group_name      = module.mod_resource_group.out_rg_name
  location                 = module.mod_resource_group.out_rg_location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"
  tags                     = local.tags
}
/*--------------
Key Vault
--------------*/
resource "azurerm_key_vault" "kv" {
  name                        = "${var.app}-kv-${var.environment}"
  location                    = module.mod_resource_group.out_rg_location
  resource_group_name         = module.mod_resource_group.out_rg_name
  tenant_id                   = data.azurerm_client_config.client_config.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  enabled_for_disk_encryption = false
  purge_protection_enabled    = false
  enable_rbac_authorization   = true
  tags                        = local.tags
}
/*--------------
Assign Key Vault permissions
--------------*/
resource "azurerm_role_assignment" "assign-key-vault-admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = data.azurerm_role_definition.kv-secret-off.name
  principal_id         = data.azurerm_client_config.client_config.object_id
}
/*----------------
Key Vault Secret - Storage Account Access Keys
----------------*/
resource "azurerm_key_vault_secret" "st-access-key" {
  name         = "${var.app}-${azurerm_storage_account.st.name}-accesskey-${var.environment}"
  value        = azurerm_storage_account.st.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id
  tags = {
    "ValidityPeriodDays" = local.expiration_days
    "ProviderAddress"    = azurerm_storage_account.st.id
    "CredentialId"       = "key1"
  }
  expiration_date = timeadd(timestamp(), "${local.expiration_days * 24}h")
  lifecycle {
    ignore_changes = [
      value,
      tags,
      expiration_date
    ]
  }
  depends_on = [azurerm_role_assignment.assign-key-vault-admin]
}
/*----------------
Service Plan for Azure Function
----------------*/
resource "azurerm_service_plan" "plan" {
  name                = "${var.app}-service-plan-${var.environment}"
  location            = module.mod_resource_group.out_rg_location
  resource_group_name = module.mod_resource_group.out_rg_name
  os_type             = "Windows"
  sku_name            = "Y1"
  tags                = local.tags
}
/*--------------
Storage Account for Azure Function
--------------*/
resource "azurerm_storage_account" "fnst" {
  name                     = replace("${var.app}fnst${var.environment}", "/[[:^alnum:]]/", "")
  resource_group_name      = module.mod_resource_group.out_rg_name
  location                 = module.mod_resource_group.out_rg_location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"
  tags                     = local.tags
}
/*--------------------------------
Function App Application Insights
--------------------------------*/
resource "azurerm_application_insights" "appi-func" {
  name                = "${var.app}-appi-fn-${var.environment}"
  resource_group_name = module.mod_resource_group.out_rg_name
  location            = module.mod_resource_group.out_rg_location
  application_type    = "web"
  tags                = local.tags
}
/*--------------
Azure Function App
--------------*/
resource "azurerm_windows_function_app" "fn" {
  name                       = "${var.app}-fn-${var.environment}"
  resource_group_name        = module.mod_resource_group.out_rg_name
  location                   = module.mod_resource_group.out_rg_location
  storage_account_name       = azurerm_storage_account.fnst.name
  storage_account_access_key = azurerm_storage_account.fnst.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id
  https_only                 = true

  site_config {
    minimum_tls_version                    = "1.2"
    application_insights_connection_string = azurerm_application_insights.appi-func.connection_string
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = false
    }
  }
  app_settings = {
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "FUNCTIONS_WORKER_RUNTIME"    = "powershell"
    "WEBSITE_RUN_FROM_PACKAGE"    = 1
  }
  identity {
    type = "SystemAssigned"
  }
  tags = local.tags
  lifecycle {
    ignore_changes = [
      app_settings,
      tags
    ]
  }
}
/*--------------
Assign ST permissions
--------------*/
resource "azurerm_role_assignment" "assign-st-key-op-to-func" {
  scope                = azurerm_storage_account.st.id
  role_definition_name = data.azurerm_role_definition.st-key-op.name
  principal_id         = azurerm_windows_function_app.fn.identity[0].principal_id
}
/*--------------
Assign Key Vault permissions
--------------*/
resource "azurerm_role_assignment" "assign-kv-off-to-func" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = data.azurerm_role_definition.kv-secret-off.name
  principal_id         = azurerm_windows_function_app.fn.identity[0].principal_id
}
/*--------------
Create Event Grid System Topic
--------------*/
resource "azurerm_eventgrid_system_topic" "rotation" {
  name                   = "${var.app}-eventgrid-sys-topic-${var.environment}"
  resource_group_name    = module.mod_resource_group.out_rg_name
  location               = module.mod_resource_group.out_rg_location
  source_arm_resource_id = azurerm_key_vault.kv.id
  topic_type             = "Microsoft.KeyVault.vaults"
  identity {
    type = "SystemAssigned"
  }
  tags = local.tags
}
/*--------------
Create EventGrid System Topic Event Subscription - Key Vault Event to Function App
--------------*/
resource "azurerm_eventgrid_system_topic_event_subscription" "st-secret-rotation" {
  name                  = "${var.app}-st-secret-rotation-${var.environment}"
  system_topic          = azurerm_eventgrid_system_topic.rotation.name
  resource_group_name   = module.mod_resource_group.out_rg_name
  event_delivery_schema = "EventGridSchema"
  included_event_types  = ["Microsoft.KeyVault.SecretNearExpiry"]
  subject_filter {
    subject_begins_with = azurerm_key_vault_secret.st-access-key.name
    subject_ends_with   = azurerm_key_vault_secret.st-access-key.name
    case_sensitive      = false
  }
  retry_policy {
    max_delivery_attempts = 30
    event_time_to_live    = 60 * 24
  }
  azure_function_endpoint {
    function_id                       = "${azurerm_windows_function_app.fn.id}/functions/${var.st_access_key_rotation_funtion_name}"
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
  }
}