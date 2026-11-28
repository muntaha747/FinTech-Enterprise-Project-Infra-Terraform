# outputs.tf: values printed after apply, and read by other stacks.

output "key_arn" {
  description = "ARN of the KMS key (RDS, S3, Secrets Manager, EBS use this)"
  value       = module.KMS_Prod_Key.key_arn
}

output "key_id" {
  description = "ID of the KMS key"
  value       = module.KMS_Prod_Key.key_id
}

output "alias_name" {
  description = "Alias of the KMS key, e.g. alias/fintech-prod-rds"
  value       = module.KMS_Prod_Key.alias_name
}

output "alias_arn" {
  description = "ARN of the alias"
  value       = module.KMS_Prod_Key.alias_arn
}