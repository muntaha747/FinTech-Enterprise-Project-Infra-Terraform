# outputs.tf: values printed after apply.

output "bucket_arns" {
  description = "ARNs of all buckets"
  value       = module.infrastructure_compliance_storage.bucket_arns
}

output "platform_bucket_arns" {
  description = "ARNs of the platform tool buckets (Loki, Velero)"
  value       = module.platform_storage.bucket_arns
}
