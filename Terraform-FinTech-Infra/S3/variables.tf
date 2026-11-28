# variables.tf: the INPUTS this stack accepts. Values are set in terraform.tfvars.

variable "region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "project_name" {
  description = "Project tag value on every bucket"
  type        = string
}

variable "stack_name" {
  description = "Stack tag value on every bucket"
  type        = string
}

variable "environment" {
  description = "Environment name, e.g. production"
  type        = string
}

variable "bucket_names" {
  description = "Names of the S3 buckets to create (must be globally unique)"
  type        = list(string)
}

variable "platform_bucket_names" {
  description = "Buckets for the EKS platform tools (Loki, Velero). Names must be globally unique."
  type        = list(string)
}

variable "state_bucket" {
  description = "S3 bucket that holds the state files"
  type        = string
}

variable "kms_state_key" {
  description = "Path of the KMS stack's state file"
  type        = string
}
