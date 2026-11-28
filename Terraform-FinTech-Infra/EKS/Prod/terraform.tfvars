# terraform.tfvars: the VALUES for the Prod EKS stack.

############################ General ############################
region       = "us-east-1"
project_name = "FinTech-Enterprise-Project"
stack_name   = "eks"
environment  = "Prod"

############################ Lookups (state files of other stacks) ############################
# Must match Networking/Prod: its backend.tf (bucket + key) and the App VPC name in its terraform.tfvars
state_bucket         = "fintech-remote-backed-statefiles"
networking_state_key = "networking/env/prod/networking.tfstate"
vpc_name             = "FinTech-App"

############################ Control plane ############################
cluster_name            = "FinTech-Cluster"
cluster_version         = "1.36"
endpoint_private_access = true
endpoint_public_access  = true
cluster_admin_arns = [
  "arn:aws:iam::503676493911:root",
  # Add back once this role exists in account 503676493911 (GitHub Actions pipeline):
  # "arn:aws:iam::503676493911:role/FinTech_Enterprise_Project_GithubActions_OIDC_Role",
]
devops_user_name = "Hassan"

############################ Team access (roles from the IAM stack) ############################
iam_state_key   = "product-iam/iam-roles.tfstate"
iam_environment = "prod"
app_team_access = "view" # dev/qa: edit, stage/prod: view
cicd_access     = "view" # dev/qa: edit, stage/prod: view (prod deploys go through Argo CD)

############################ Node groups ############################
# blue = only blue groups, green = only green groups, both = all four groups
node_color           = "both"
data_plane_blue      = "Core_Services_Blue_Node_Group"
data_plane_green     = "Core_Services_Green_Node_Group"
ml_data_plane_blue   = "Machine_Learning_Blue_Node_Group"
ml_data_plane_green  = "Machine_Learning_Green_Node_Group"
node_instance_types  = ["m6a.2xlarge"]
core_blue_node_count = 3
standby_node_count   = 0
node_max_size        = 10

############################ Cluster Autoscaler ############################
cluster_autoscaler_chart_version = "9.60.0"
cluster_autoscaler_image_tag     = "v1.36.2" # keep in step with cluster_version (1.36 -> v1.36.x)
