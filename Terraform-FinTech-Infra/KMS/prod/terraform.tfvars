# terraform.tfvars: the VALUES for this KMS stack.

region                  = "us-east-1"
environment             = "prod"
key_name                = "data"
description             = "Encrypts FinTech Prod databases and S3 buckets"
deletion_window_in_days = 7 # AWS allows 7-30
multi_region            = true
enable_key_rotation     = true

tags = {
  Project   = "FinTech"
  Owner     = "DevOps"
  ManagedBy = "Terraform"
}