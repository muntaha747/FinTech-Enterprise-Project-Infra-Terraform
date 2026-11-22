module "KMS_QA_Key" {
  source                  = "../modules"
  region                  = var.region
  description             = var.description
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
  environment             = var.environment
  key_name                = var.key_name
  multi_region            = var.multi_region
  tags                    = var.tags
}
