resource "azurerm_key_vault" "keyvault" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_secret" "storage_key" {
  name         = "storage-access-key"
  value        = "clave-inicial"
  key_vault_id = azurerm_key_vault.keyvault.id
}
