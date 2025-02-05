/*---------------------------------------------
Assign permissions to the function app
---------------------------------------------*/

# variable "function_app_object_id" {
#   description = "value"
#   type        = string
#   default     = "3f0a70d1-d1dc-4cba-be93-8c13a1d75577"
# }

# data "azuread_application_published_app_ids" "well_known" {}

# data "azuread_service_principal" "msgraph" {
#   client_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
# }

# output "app_role_id" {
#   value = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
# }

# resource "azuread_app_role_assignment" "app_role_assignment" {
#   app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
#   principal_object_id = var.function_app_object_id
#   resource_object_id  = data.azuread_service_principal.msgraph.object_id
# }