# main.tf: WHAT to build. Values come from terraform.tfvars (through variables.tf).

# The AWS account ID of the credentials you are using
data "aws_caller_identity" "current" {}

# The module runs once per entry in role_sets (platform, dev, qa, stage, prod).
# for_each: removing one environment later does not touch the others.
module "iam_roles" {
  source   = "./modules/iam_roles"
  for_each = var.role_sets

  account_id           = data.aws_caller_identity.current.account_id
  env_type             = each.key
  enable_platform_role = each.value.enable_platform_role
  enable_product_role  = each.value.enable_product_role
  enable_cicd_role     = each.value.enable_cicd_role
}
