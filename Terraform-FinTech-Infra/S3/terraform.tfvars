# terraform.tfvars: the VALUES for this stack. Add a bucket by adding a name.
# Every name ends with the AWS account ID (503676493911), because bucket names are global across all of AWS.
region       = "us-east-1"
project_name = "FinTech-Enterprise-Project"
stack_name   = "s3"
environment  = "Dev"
bucket_names = [
  "muntaha-fintech-dvc-data-lake-503676493911",
  "muntaha-fintech-applog-503676493911",
  "muntaha-fintech-rawdata-applog-503676493911"
]

# Buckets for the EKS platform tools (Platform-Addons stack uses these exact names)
platform_bucket_names = [
  "fintech-dev-loki-bucket-503676493911",   # Loki logs (Dev)
  "fintech-dev-velero-bucket-503676493911", # Velero backups (Dev)
]

# Every bucket is encrypted with the Dev KMS key (read from the KMS stack's state)
state_bucket  = "fintech-remote-backed-statefiles"
kms_state_key = "kms/env/dev/kms.tfstate"
