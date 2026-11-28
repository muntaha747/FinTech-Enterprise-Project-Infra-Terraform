# locals.tf: values WORKED OUT from the variables and lookups.

locals {
  # Tags added to every resource
  common_tags = {
    Project = var.project_name
    Stack   = var.stack_name
  }

  # Networking outputs are maps: VPC name => value. Pick the Ops VPC.
  networking            = data.terraform_remote_state.networking.outputs
  ops_vpc_id            = local.networking.vpc_ids[var.ops_vpc_name]
  ops_private_subnet_id = local.networking.private_subnet_ids[var.ops_vpc_name][0]
}
