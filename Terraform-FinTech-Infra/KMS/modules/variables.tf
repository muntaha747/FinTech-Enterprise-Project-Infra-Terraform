# variables.tf: inputs of the KMS module.

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
  default     = true
}

variable "deletion_window_in_days" {
  description = "Days to wait before a deleted key is gone for good (7-30)"
  type        = number
  default     = 30
}

variable "multi_region" {
  description = "Make the key usable in other regions (disaster recovery)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags added to the key"
  type        = map(string)
  default     = {}
}
