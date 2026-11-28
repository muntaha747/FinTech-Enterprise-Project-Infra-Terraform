# variables.tf: the INPUTS this stack accepts. Values are set in terraform.tfvars.

variable "region" {
  description = "AWS region of the key"
  type        = string
}

variable "description" {
  description = "What this key encrypts"
  type        = string
}

variable "environment" {
  description = "Environment name: dev, qa, stage or prod"
  type        = string
}

variable "key_name" {
  description = "Short name of the key, e.g. data"
  type        = string
}

variable "enable_key_rotation" {
  description = "Rotate the key automatically every year"
  type        = bool
}

variable "deletion_window_in_days" {
  description = "Days to wait before a deleted key is gone for good (7-30)"
  type        = number
}

variable "multi_region" {
  description = "Make the key usable in other regions (disaster recovery)"
  type        = bool
}

variable "tags" {
  description = "Extra tags added to the key"
  type        = map(string)
}
