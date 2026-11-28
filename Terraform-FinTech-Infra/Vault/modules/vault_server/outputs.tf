# outputs.tf: values this module hands back to the root.

output "vault_private_ip" {
  description = "Private IP of the Vault server"
  value       = aws_instance.vault.private_ip
}

output "vault_address" {
  description = "URL other stacks use to reach Vault"
  value       = "http://${aws_instance.vault.private_ip}:8200"
}

output "vault_instance_id" {
  description = "EC2 instance ID (use it with: aws ssm start-session --target <id>)"
  value       = aws_instance.vault.id
}
