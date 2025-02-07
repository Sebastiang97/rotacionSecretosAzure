output "out_rg_name" {

  value = data.azurerm_resource_group.az-rg.name
}

output "out_rg_location" {

  value = data.azurerm_resource_group.az-rg.location
}