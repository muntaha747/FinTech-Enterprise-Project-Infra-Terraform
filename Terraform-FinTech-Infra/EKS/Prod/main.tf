# main.tf: WHAT to build. Values come from terraform.tfvars (through variables.tf) and locals.tf.

# Reads the outputs of this environment's Networking stack (read-only).
# This is how EKS finds the VPC subnets, so Networking must be applied first.
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = var.networking_state_key
    region = var.region
  }
}

# Reads the IAM stack's outputs: the platform admin, app team and CI/CD roles.
# IAM must be applied before EKS.
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = var.iam_state_key
    region = var.region
  }
}

# The whole EKS platform: control plane, node groups, IAM, OIDC and Cluster Autoscaler
module "eks_cluster" {
  source = "../modules/eks_cluster"

  # General
  region      = var.region
  environment = var.environment
  tags        = local.common_tags

  # Control plane
  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  private_subnet_ids        = local.private_subnet_ids
  cluster_security_group_id = local.cluster_sg_id
  endpoint_private_access   = var.endpoint_private_access
  endpoint_public_access    = var.endpoint_public_access
  cluster_admin_arns        = var.cluster_admin_arns
  devops_user_name          = var.devops_user_name

  # Team access (roles from the IAM stack)
  team_roles = local.team_roles

  # Node groups
  node_color           = var.node_color
  data_plane_blue      = var.data_plane_blue
  data_plane_green     = var.data_plane_green
  ml_data_plane_blue   = var.ml_data_plane_blue
  ml_data_plane_green  = var.ml_data_plane_green
  node_instance_types  = var.node_instance_types
  core_blue_node_count = var.core_blue_node_count
  standby_node_count   = var.standby_node_count
  node_max_size        = var.node_max_size

  # Cluster Autoscaler
  cluster_autoscaler_chart_version = var.cluster_autoscaler_chart_version
  cluster_autoscaler_image_tag     = var.cluster_autoscaler_image_tag
}