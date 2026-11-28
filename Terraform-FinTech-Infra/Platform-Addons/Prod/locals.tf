# locals.tf: values WORKED OUT from the variables and lookups.

locals {
  # Tags added to every resource
  common_tags = {
    Project = var.project_name
    Stack   = var.stack_name
  }

  eks           = data.terraform_remote_state.eks.outputs
  vault_address = data.terraform_remote_state.vault.outputs.vault_address
}
