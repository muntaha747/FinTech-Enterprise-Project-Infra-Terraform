# outputs.tf: values this module hands back to the root.

output "grafana_admin_password" {
  description = "Grafana admin password (user: admin)"
  value       = random_password.grafana_admin.result
  sensitive   = true
}
