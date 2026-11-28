# locals.tf: values WORKED OUT from the variables and lookups.

locals {
  # Tags added to every resource
  common_tags = {
    Project = var.project_name
    Stack   = var.stack_name
  }

  # Networking outputs are maps: VPC name => value. Pick the VPC this cluster lives in.
  networking         = data.terraform_remote_state.networking.outputs
  private_subnet_ids = local.networking.private_subnet_ids[var.vpc_name]
  cluster_sg_id      = local.networking.private_security_group_ids[var.vpc_name]

  # IAM outputs: the three team roles, and how much each may do on this cluster
  iam = data.terraform_remote_state.iam.outputs
  team_roles = {
    platform_admin = { role_arn = local.iam.platform_role_arn, access = "admin" }
    app_team       = { role_arn = local.iam.app_team_role_arns[var.iam_environment], access = var.app_team_access }
    cicd_deployer  = { role_arn = local.iam.cicd_role_arns[var.iam_environment], access = var.cicd_access }
  }
}
