locals {
  tags = {
    name_app    = var.app
    environment = var.environment
    owner       = "ssanabrg"
  }
  app = var.app

  expiration_days = (var.total_st_access_key_days / 2) + 30
}