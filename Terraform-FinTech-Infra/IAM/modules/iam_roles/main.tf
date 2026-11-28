# main.tf: the IAM roles for ONE environment (the root calls this once per environment).
#   Role 1: FinTech-Platform-Admin          (only for the "platform" entry)
#   Role 2: AppTeam-<env>-Role              (developers / QA)
#   Role 3: FinTech-CI-CD-Deployer-<env>    (GitHub Actions)
# Each role is switched on or off with count = 1 / 0.

locals {
  # prod and stage get read-only permissions, the rest get full access
  is_read_only = contains(var.read_only_environments, var.env_type)

  # Who may assume roles 1 and 2: IAM users/roles of this AWS account
  account_root_arn = "arn:aws:iam::${var.account_id}:root"

  # Who may assume role 3: GitHub Actions, from this one repository only
  github_oidc_arn = "arn:aws:iam::${var.account_id}:oidc-provider/${var.github_oidc_host}"
  github_owner    = split("/", var.github_repo)[0]
  github_repo     = split("/", var.github_repo)[1]
  github_subject  = "repo:${local.github_owner}@${var.github_owner_id}/${local.github_repo}@${var.github_repo_id}:*"
}

############################ Role 1: Platform admin ############################
resource "aws_iam_role" "platform" {
  count = var.enable_platform_role ? 1 : 0
  name  = var.platform_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = local.account_root_arn }
    }]
  })
}

# AWS managed policies (VPC, RDS full access)
resource "aws_iam_role_policy_attachment" "platform" {
  for_each   = var.enable_platform_role ? var.platform_managed_policies : {}
  role       = aws_iam_role.platform[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "platform" {
  count = var.enable_platform_role ? 1 : 0
  name  = "${var.platform_role_name}-policy"
  role  = aws_iam_role.platform[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Sid = "ManageEKS", Effect = "Allow", Action = var.platform_eks_actions, Resource = "*" },
      { Sid = "ManageKMS", Effect = "Allow", Action = var.platform_kms_actions, Resource = "*" },
      { Sid = "DenyPIIDataAccess", Effect = "Deny", Action = var.platform_denied_data_actions, Resource = "*" },
    ]
  })
}

############################ Role 2: App team ############################
resource "aws_iam_role" "app_team" {
  count = var.enable_product_role ? 1 : 0
  name  = "${var.app_team_role_prefix}-${var.env_type}-Role" # e.g. AppTeam-qa-Role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = local.account_root_arn }
    }]
  })
}

resource "aws_iam_role_policy" "app_team" {
  count = var.enable_product_role ? 1 : 0
  name  = "${var.app_team_role_prefix}-${var.env_type}-policy"
  role  = aws_iam_role.app_team[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EKSAndRDS"
        Effect   = "Allow"
        Action   = local.is_read_only ? var.app_team_read_only_actions : var.app_team_full_actions
        Resource = "*"
      },
      {
        Sid      = "DatabaseConnect" # connect only as <env>_user, e.g. qa_user
        Effect   = "Allow"
        Action   = ["rds-db:connect"]
        Resource = "arn:aws:rds-db:*:*:dbuser:*/${var.env_type}${var.db_user_suffix}"
      },
      {
        Sid      = "Guardrail"
        Effect   = "Deny"
        Action   = var.app_team_denied_actions
        Resource = "*"
      },
    ]
  })
}

############################ Role 3: CI/CD deployer (GitHub Actions) ############################
resource "aws_iam_role" "cicd" {
  count = var.enable_cicd_role ? 1 : 0
  name  = "${var.cicd_role_prefix}-${var.env_type}" # e.g. FinTech-CI-CD-Deployer-qa

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = local.github_oidc_arn }
      Condition = {
        StringLike = { "${var.github_oidc_host}:sub" = local.github_subject }
      }
    }]
  })
}

resource "aws_iam_role_policy" "cicd" {
  count = var.enable_cicd_role ? 1 : 0
  name  = "${var.cicd_role_prefix}-${var.env_type}-policy"
  role  = aws_iam_role.cicd[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Sid = "PushImages", Effect = "Allow", Action = var.cicd_ecr_actions, Resource = "*" },
      {
        Sid      = "UpdateEKS"
        Effect   = "Allow"
        Action   = local.is_read_only ? var.cicd_eks_read_only_actions : var.cicd_eks_full_actions
        Resource = "*"
      },
      { Sid = "ReadSecrets", Effect = "Allow", Action = var.cicd_secret_actions, Resource = "*" },
    ]
  })
}
