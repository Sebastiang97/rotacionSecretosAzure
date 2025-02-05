/*---------------------------------------------
Azure Provider source and version being used
---------------------------------------------*/
terraform {
  required_version = ">= 1.3.7"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.0"
    }
  }
}
/*---------------------------------------------
Configure the Microsoft Azure AD Provider
---------------------------------------------*/
provider "azuread" {
}
/*---------------------------------------------
Configure the Microsoft Azure General Provider
---------------------------------------------*/
provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}