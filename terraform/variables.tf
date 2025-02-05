variable "subscription_id" {
  description = "The id of the subscription that will be used to create the resources in Azure"
  type        = string
}

variable "tenant_id" {
  description = "The id of the Azure tenant id to manage"
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group to be created"
  type        = string
  default     = "East US"
}

variable "app" {
  description = "Application name"
  type        = string
  default     = "srs"
}

variable "environment" {
  description = "Environment to be used on all the resources as identifier"
  type        = string
  default     = null
}

# variable "st_rotate_keys_time" {
#   description = "The time in hours to set as expiration date for the storage account access keys. 90 days are default "
#   type        = string
#   default     = "2160"
# }

variable "total_st_access_key_days" {
  description = "The total days that a storage account's access key will be valid for. 90 days are default "
  type        = number
  default     = 90
}

variable "st_access_key_rotation_funtion_name" {
  description = "Azure Function Name to rotate storage accounts' access keys"
  type        = string
  default     = "StorageAccounfAccessKeyRotation"
}

/*------------------
Azure AD Variables
------------------*/
variable "ad_sign_in_audience" {
  description = "(Optional) Account types that are supported for the current application"
  type        = string
  default     = "AzureADMyOrg"
}