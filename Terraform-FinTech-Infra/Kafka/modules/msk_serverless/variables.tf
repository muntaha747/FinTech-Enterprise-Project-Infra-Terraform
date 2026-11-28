# variables.tf: inputs of the MSK Serverless module.

variable "cluster_name" {
  description = "Name of the Kafka cluster (letters, numbers and hyphens)"
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
  description = "App VPC ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "App VPC CIDR (allowed to reach Kafka)"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnets for Kafka: one per AZ (2 or 3 subnets)"
  type        = list(string)
}
