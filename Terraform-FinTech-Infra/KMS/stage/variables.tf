variable "region" {
  description = "Key Region"
  type        = string
}

variable "description" {
  description = "What this key encrypts"
  type        = string
}
variable "enable_key_rotation" {
  description = "enabling that key should be rotated"
  type        = bool
  default     = true
}

variable "deletion_window_in_days" {
  description = "Days to wait before a deleted key is gone for good (7-30)"
  type        = number
}

variable "environment" {
  description = "Environment name: dev, qa, stage or prod"
  type        = string
}

variable "key_name" {
  description = "Short name of the key, e.g. rds or s3"
  type        = string
}

variable "multi_region" {
  description = "This Key is valid in multi region for the disaster recovery issue"
  type        = bool
}

variable "tags" {
  description = "Extra tags to add to the key"
  type        = map(string)
  default = {
    Project = "FinTech"
  }
}