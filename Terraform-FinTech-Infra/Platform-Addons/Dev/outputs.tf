# outputs.tf: values printed after apply.

output "grafana_admin_password" {
  description = "Grafana admin password (user: admin). Show it with: terraform output -raw grafana_admin_password"
  value       = module.platform_addons.grafana_admin_password
  sensitive   = true
}
