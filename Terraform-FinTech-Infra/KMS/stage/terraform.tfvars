# terraform.tfvars: the VALUES for this KMS stack.

region                  = "us-east-1"
environment             = "stage"
key_name                = "data"
description             = "Encrypts FinTech Stage databases and S3 buckets"
deletion_window_in_days = 30
multi_region            = true
enable_key_rotation     = true

tags = {
  Project   = "FinTech"
  Owner     = "DevOps"
  ManagedBy = "Terraform"
}
