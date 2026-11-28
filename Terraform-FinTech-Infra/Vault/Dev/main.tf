# main.tf: WHAT to build. Values come from terraform.tfvars (through variables.tf) and locals.tf.

# Reads this environment's Networking outputs (Ops VPC and its subnets)
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = var.networking_state_key
    region = var.region
  }
}

# Vault server on EC2 in the Ops VPC
module "vault_server" {
  source = "../modules/vault_server"

  vault_name          = var.vault_name
  environment         = var.environment
  tags                = local.common_tags
  vpc_id              = local.ops_vpc_id
  subnet_id           = local.ops_private_subnet_id
  allowed_cidr_blocks = var.allowed_cidr_blocks
  instance_type       = var.instance_type
}
