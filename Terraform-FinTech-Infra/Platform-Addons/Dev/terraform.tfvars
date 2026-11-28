# terraform.tfvars: the VALUES for the Dev Platform-Addons stack.

############################ General ############################
region       = "us-east-1"
project_name = "FinTech-Enterprise-Project"
stack_name   = "platform-addons"
environment  = "Dev"

############################ Lookups ############################
state_bucket    = "fintech-remote-backed-statefiles"
eks_state_key   = "eks/env/dev/eks.tfstate"
vault_state_key = "vault/env/dev/vault.tfstate"
kms_state_key   = "kms/env/dev/kms.tfstate"

############################ S3 buckets (created by the S3 stack: apply S3 first) ############################
loki_bucket_name   = "fintech-dev-loki-bucket-503676493911"
velero_bucket_name = "fintech-dev-velero-bucket-503676493911"

############################ Versions ############################
# Helm chart versions (checked with `helm search repo` on 2026-11-27)
chart_versions = {
  kube_prometheus_stack  = "94.2.0"
  loki                   = "7.7.0"
  alloy                  = "1.16.0"
  fluent_bit             = "0.58.3"
  argo_cd                = "10.20.0"
  argo_rollouts          = "2.43.12"
  falco                  = "9.2.2"
  velero                 = "12.2.5"
  vault_secrets_operator = "2.0.0"
  keda                   = "2.21.1"
}
velero_aws_plugin_version = "v1.14.4" # must match Velero 1.18 (chart 12.2.5)

############################ Settings ############################
prometheus_retention = "15d"
prometheus_disk_size = "50Gi"
