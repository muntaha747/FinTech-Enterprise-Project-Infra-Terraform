# locals.tf: values WORKED OUT from the variables and lookups.

locals {
  # Tags added to every resource
  common_tags = {
    Project = var.project_name
    Stack   = var.stack_name
  }

  # Networking outputs are maps: VPC name => value. Pick the App VPC.
  networking   = data.terraform_remote_state.networking.outputs
  app_vpc_id   = local.networking.vpc_ids[var.vpc_name]
  app_vpc_cidr = local.networking.vpc_cidr_blocks[var.vpc_name]

  # Private subnets 1, 2 and 3 of the App VPC (x.x.11.0, x.x.12.0, x.x.13.0 = one per AZ).
  # The list is sorted by CIDR, so the first three are always these.
  kafka_subnet_ids = slice(local.networking.private_subnet_ids[var.vpc_name], 0, 3)
}
