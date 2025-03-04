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

module "keyvault" {
  source              = "./modules/keyvault"
  key_vault_name      = "myKeyVaultKely"
  resource_group_name = module.mod_resource_group.out_rg_name
  location            = module.mod_resource_group.out_rg_location
  tenant_id           = var.tenant_id
}

module "function" {
  source              = "./modules/function"
  resource_group_name = module.mod_resource_group.out_rg_name
  location            = module.mod_resource_group.out_rg_location
  key_vault_url       = module.keyvault.key_vault_id
}

module "eventgrid" {
  source              = "./modules/eventgrid"
  resource_group_name = module.mod_resource_group.out_rg_name
  location            = module.mod_resource_group.out_rg_location
  key_vault_id        = module.keyvault.key_vault_id
  function_id         = module.function.function_id
}

