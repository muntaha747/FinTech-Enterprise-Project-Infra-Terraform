# terraform.tfvars: the VALUES for this stack. Add a repository by adding a name.
region       = "us-east-1"
project_name = "FinTech-Enterprise-Project"
stack_name   = "ecr"

repository_names = [
  "fintech-ledgerservice",
  "fintech-payment",
  "fintech-bff",
  "fintech-notifications",
]

# IMMUTABLE: push a new tag every time (e.g. the git SHA), never re-push "latest"
image_mutability = "IMMUTABLE"
