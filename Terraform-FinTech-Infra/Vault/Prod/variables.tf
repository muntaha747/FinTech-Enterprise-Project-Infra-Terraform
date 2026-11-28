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

############################ Networking lookup ############################
variable "state_bucket" {
  description = "S3 bucket that holds the state files"
  type        = string
}

variable "networking_state_key" {
  description = "Path of this environment's Networking state file"
  type        = string
}

variable "ops_vpc_name" {
  description = "Name of the Ops VPC (a key of the Networking outputs)"
  type        = string
}

############################ Vault server ############################
variable "vault_name" {
  description = "Name of the Vault server"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type of the Vault server"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "Networks allowed to call the Vault API on port 8200"
  type        = list(string)
}
