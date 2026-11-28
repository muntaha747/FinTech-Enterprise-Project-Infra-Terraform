# variables.tf: inputs of the Vault server module.

variable "vault_name" {
  description = "Name of the Vault server (used as a prefix for its resources)"
  type        = string
}

variable "environment" {
  description = "Environment tag value: Prod, Stage, QA or Dev"
  type        = string
}

variable "tags" {
  description = "Extra tags added to every resource"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "Ops VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet of the Ops VPC to place Vault in"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "Networks allowed to call the Vault API on port 8200"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type of the Vault server"
  type        = string
  default     = "t3.medium"
}

variable "disk_size_gb" {
  description = "Size of the Vault server's disk in GB"
  type        = number
  default     = 30
}
