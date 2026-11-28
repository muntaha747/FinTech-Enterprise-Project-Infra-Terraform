# main.tf: WHAT to build. Values come from terraform.tfvars (through variables.tf).

# One private ECR repository per name in terraform.tfvars
module "ecr_repo" {
  source           = "./modules/ecr_repository"
  repository_names = var.repository_names
  image_mutability = var.image_mutability
  tags             = local.common_tags
}
