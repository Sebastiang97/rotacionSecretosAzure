/*--------------
Data Key Vault Secrets Officer build-in role
--------------*/
data "azurerm_role_definition" "kv-secret-off" {
  name = "Key Vault Secrets Officer"
}
/*--------------
Storage Account Key Operator build-in role
--------------*/
data "azurerm_role_definition" "st-key-op" {
  name = "Storage Account Key Operator Service Role"
}