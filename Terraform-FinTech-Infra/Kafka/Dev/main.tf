# main.tf: WHAT to build. Values come from terraform.tfvars (through variables.tf) and locals.tf.

# Reads this environment's Networking outputs (App VPC and its subnets)
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = var.networking_state_key
    region = var.region
  }
}

# Kafka (MSK Serverless) in private subnets 1, 2 and 3 of the App VPC
module "kafka" {
  source = "../modules/msk_serverless"

  cluster_name   = var.cluster_name
  environment    = var.environment
  tags           = local.common_tags
  vpc_id         = local.app_vpc_id
  vpc_cidr_block = local.app_vpc_cidr
  subnet_ids     = local.kafka_subnet_ids
}
