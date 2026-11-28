# main.tf: WHAT to build. Values come from terraform.tfvars (through variables.tf).

# Reads the KMS stack's outputs (the key that encrypts every bucket).
# KMS/<env> (the one in kms_state_key) must be applied before S3.
data "terraform_remote_state" "kms" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = var.kms_state_key
    region = var.region
  }
}

# One bucket per name in terraform.tfvars
module "infrastructure_compliance_storage" {
  source       = "./modules/s3_bucket"
  environment  = var.environment
  bucket_names = var.bucket_names
  kms_key_arn  = data.terraform_remote_state.kms.outputs.key_arn
  tags         = local.common_tags
}

# Buckets the EKS platform tools use (Loki logs, Velero backups).
# Same module, but no lifecycle rule (Loki and Velero clean up their own data)
# and no versioning (they delete old data on purpose).
module "platform_storage" {
  source                = "./modules/s3_bucket"
  environment           = var.environment
  bucket_names          = var.platform_bucket_names
  versioning_status     = "Disabled"
  lifecycle_rule_status = "Disabled"
  kms_key_arn           = data.terraform_remote_state.kms.outputs.key_arn
  tags                  = local.common_tags
}
