# variables.tf: the INPUTS this stack accepts. Values are set in terraform.tfvars.

############################ General ############################
variable "region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "project_name" {
  description = "Project tag value on every resource"
  type        = string
}

variable "stack_name" {
  description = "Stack tag value on every resource"
  type        = string
}

variable "environment" {
  description = "Environment name: Prod, Stage, QA or Dev"
  type        = string
}

############################ Lookups ############################
variable "state_bucket" {
  description = "S3 bucket that holds the state files"
  type        = string
}

variable "eks_state_key" {
  description = "Path of this environment's EKS state file"
  type        = string
}

variable "kms_state_key" {
  description = "Path of the KMS stack's state file"
  type        = string
}

variable "vault_state_key" {
  description = "Path of this environment's Vault state file"
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

############################ Versions ############################
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
  description = "Image tag of the Velero AWS plugin"
  type        = string
}

############################ Settings ############################
variable "prometheus_retention" {
  description = "How long Prometheus keeps metrics"
  type        = string
}

variable "prometheus_disk_size" {
  description = "Prometheus disk size"
  type        = string
}
