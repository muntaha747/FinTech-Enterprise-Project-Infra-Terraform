output "key_arn" {
  description = "ARN of the KMS key (RDS, S3, Secrets Manager, EBS use this)"
  value       = aws_kms_key.FinTech_Prod_Key.arn
}

output "key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.FinTech_Prod_Key.key_id
}

output "alias_name" {
  description = "Alias of the KMS key, e.g. alias/fintech-prod-rds"
  value       = aws_kms_alias.friendly_key_name.name
}

output "alias_arn" {
  description = "ARN of the alias"
  value       = aws_kms_alias.friendly_key_name.arn
}