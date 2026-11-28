# variables.tf: inputs of the platform add-ons module.

############################ Cluster ############################
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS region of the cluster"
  type        = string
}

variable "environment" {
  description = "Environment tag value: Prod, Stage, QA or Dev"
  type        = string
}

variable "tags" {
  description = "Extra tags added to every AWS resource"
  type        = map(string)
  default     = {}
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster's OIDC provider (for pod IAM roles)"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the cluster's OIDC issuer"
  type        = string
}

############################ S3 buckets (created by the S3 stack) ############################
variable "loki_bucket_name" {
  description = "S3 bucket where Loki stores logs"
  type        = string
}

variable "velero_bucket_name" {
  description = "S3 bucket where Velero stores backups"
  type        = string
}

variable "s3_kms_key_arn" {
  description = "KMS key that encrypts the Loki and Velero buckets"
  type        = string
}

############################ Namespace ############################
variable "namespace" {
  description = "Kubernetes namespace every platform tool is installed in"
  type        = string
  default     = "platform-tools"
}

############################ Chart versions ############################
# Pinned so every environment installs exactly the same thing
variable "chart_versions" {
  description = "Helm chart version of each tool"
  type = object({
    kube_prometheus_stack  = string
    loki                   = string
    alloy                  = string
    fluent_bit             = string
    argo_cd                = string
    argo_rollouts          = string
    falco                  = string
    velero                 = string
    vault_secrets_operator = string
    keda                   = string
  })
}

variable "velero_aws_plugin_version" {
  description = "Image tag of the Velero AWS plugin, e.g. v1.12.0"
  type        = string
}

############################ Settings ############################
variable "prometheus_retention" {
  description = "How long Prometheus keeps metrics, e.g. 15d"
  type        = string
  default     = "15d"
}

variable "prometheus_disk_size" {
  description = "Prometheus disk size, e.g. 50Gi"
  type        = string
  default     = "50Gi"
}

variable "vault_address" {
  description = "URL of the Vault server in the Ops VPC, e.g. http://10.40.11.10:8200"
  type        = string
}
