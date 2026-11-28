# main.tf: WHAT to build. Values come from terraform.tfvars (through variables.tf) and locals.tf.

# Reads the EKS stack's outputs (cluster name, OIDC provider)
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = var.eks_state_key
    region = var.region
  }
}

# Reads the Vault stack's outputs (Vault address)
data "terraform_remote_state" "vault" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = var.vault_state_key
    region = var.region
  }
}

# Reads the KMS stack's outputs (the key that encrypts the Loki and Velero buckets)
data "terraform_remote_state" "kms" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = var.kms_state_key
    region = var.region
  }
}

# Cluster details the Helm and Kubernetes providers need (providers.tf)
data "aws_eks_cluster" "eks" {
  name = local.eks.cluster_name
}

# All the platform tools: monitoring, logging, GitOps, security, backup
module "platform_addons" {
  source = "../modules/platform_addons"

  # Cluster
  cluster_name      = local.eks.cluster_name
  region            = var.region
  environment       = var.environment
  tags              = local.common_tags
  oidc_provider_arn = local.eks.oidc_provider_arn
  oidc_provider_url = local.eks.oidc_provider_url

  # S3 buckets (created by the S3 stack)
  loki_bucket_name   = var.loki_bucket_name
  velero_bucket_name = var.velero_bucket_name
  s3_kms_key_arn     = data.terraform_remote_state.kms.outputs.key_arn

  # Versions
  chart_versions            = var.chart_versions
  velero_aws_plugin_version = var.velero_aws_plugin_version

  # Settings
  prometheus_retention = var.prometheus_retention
  prometheus_disk_size = var.prometheus_disk_size
  vault_address        = local.vault_address
}
