# outputs.tf: values printed after apply, and read by the Platform-Addons stack.

output "vault_address" {
  description = "URL to reach Vault"
  value       = module.vault_server.vault_address
}

output "vault_instance_id" {
  description = "EC2 instance ID (aws ssm start-session --target <id>)"
  value       = module.vault_server.vault_instance_id
}
