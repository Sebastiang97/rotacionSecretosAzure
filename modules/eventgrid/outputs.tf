output "eventgrid_topic_id" {
  value = azurerm_eventgrid_system_topic.keyvault_events.id
}
