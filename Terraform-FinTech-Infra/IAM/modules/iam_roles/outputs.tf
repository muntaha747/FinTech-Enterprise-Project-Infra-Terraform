# outputs.tf: values this module hands back to the root (null when a role is switched off).

output "platform_role_arn" {
  description = "ARN of FinTech-Platform-Admin"
  value       = try(aws_iam_role.platform[0].arn, null)
}

output "app_team_role_arn" {
  description = "ARN of AppTeam-<env>-Role"
  value       = try(aws_iam_role.app_team[0].arn, null)
}

output "cicd_role_arn" {
  description = "ARN of FinTech-CI-CD-Deployer-<env>"
  value       = try(aws_iam_role.cicd[0].arn, null)
}
