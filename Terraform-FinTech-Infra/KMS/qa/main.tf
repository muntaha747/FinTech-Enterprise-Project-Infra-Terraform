# main.tf: WHAT to build. Values come from terraform.tfvars (through variables.tf).

module "KMS_QA_Key" {
  source = "../modules"

  description             = var.description
  environment             = var.environment
  key_name                = var.key_name
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
  multi_region            = var.multi_region
  tags                    = var.tags
}
