/*--------------
Pruebas de otro tema
--------------*/
# data "azurerm_data_factory" "adf" {
#   name                = "shared-data-factory-poc"
#   resource_group_name = "shared-encrypt-poc"
# }

# resource "azurerm_data_factory_linked_service_azure_blob_storage" "df_link_service_st_ift" {
#   name                     = "shared-link-service-sharedstencryptpoc-st-poc"
#   data_factory_id          = data.azurerm_data_factory.adf.id
#   service_endpoint         = "https://sharedstencryptpoc.blob.core.windows.net/"
#   integration_runtime_name = "shared-runtime-poc"
#   use_managed_identity     = true
#   storage_kind             = "StorageV2"
# }

# resource "azapi_resource" "adf_link_service_parameterized" {
#   type      = "Microsoft.DataFactory/factories/linkedservices@2018-06-01"
#   name      = "shared-link-service-parameterized-st-poc"
#   parent_id = data.azurerm_data_factory.adf.id

#   body = jsonencode({
#     properties = {
#       parameters = {
#         storageAccountName = {
#           type = "string"
#         }
#       }
#       annotations = []
#       type        = "AzureBlobStorage"
#       typeProperties = {
#         serviceEndpoint = "@{concat('https://',linkedService().storageAccountName,'.blob.core.windows.net')}",
#         accountKind     = "StorageV2"
#         authenticationType = "Msi"
#       },
#       connectVia = {
#         referenceName = "shared-runtime-poc"
#         type          = "IntegrationRuntimeReference"
#       }
#     }
#   })
# }
