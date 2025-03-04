resource "azurerm_eventgrid_system_topic" "keyvault_events" {
  name                   = "keyvault-eventgrid"
  location               = var.location
  resource_group_name    = var.resource_group_name
  source_arm_resource_id = var.key_vault_id
  topic_type             = "Microsoft.KeyVault.vaults"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "keyvault_secret_rotation" {
  name                          = "kv-secret-rotation"
  system_topic                  = azurerm_eventgrid_system_topic.keyvault_events.name
  resource_group_name           = var.resource_group_name
  event_delivery_schema         = "EventGridSchema"

  azure_function_endpoint {
    function_id = var.function_id
  }
}
