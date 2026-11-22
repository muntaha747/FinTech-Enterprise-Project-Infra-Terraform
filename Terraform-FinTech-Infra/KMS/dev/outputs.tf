output "key_arn" {
  description = "ARN of the KMS key (RDS, S3, Secrets Manager, EBS use this)"
  value       = module.KMS_Dev_Key.key_arn
}

output "key_id" {
  description = "ID of the KMS key"
  value       = module.KMS_Dev_Key.key_id
}

output "alias_name" {
  description = "Alias of the KMS key, e.g. alias/fintech-dev-data"
  value       = module.KMS_Dev_Key.alias_name
}

output "alias_arn" {
  description = "ARN of the alias"
  value       = module.KMS_Dev_Key.alias_arn
}
