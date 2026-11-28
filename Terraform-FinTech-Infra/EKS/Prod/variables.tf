# variables.tf: the INPUTS this stack accepts. Values are set in terraform.tfvars.
# No defaults here on purpose: every value is visible in terraform.tfvars.

############################ General ############################
variable "region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "project_name" {
  description = "Project tag value on every resource"
  type        = string
}

variable "stack_name" {
  description = "Stack tag value on every resource"
  type        = string
}

variable "environment" {
  description = "Environment name: Prod, Stage, QA or Dev"
  type        = string
}

############################ Networking lookup ############################
variable "state_bucket" {
  description = "S3 bucket that holds the state files (Networking and IAM)"
  type        = string
}

variable "networking_state_key" {
  description = "Path of this environment's Networking state file inside the bucket"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC (a key of the Networking outputs) the cluster is placed in"
  type        = string
}

############################ Control plane ############################
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
}

variable "endpoint_private_access" {
  description = "Allow access to the EKS API from inside the VPC"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Allow access to the EKS API from the internet"
  type        = bool
}

variable "cluster_admin_arns" {
  description = "IAM users/roles that get cluster-admin on EKS (the creator is skipped automatically)"
  type        = list(string)
}

variable "devops_user_name" {
  description = "Name of the DevOps IAM user (must be unique per environment)"
  type        = string
}

############################ Team access ############################
variable "iam_state_key" {
  description = "Path of the IAM stack's state file"
  type        = string
}

variable "iam_environment" {
  description = "This environment's name in the IAM stack (dev, qa, stage or prod)"
  type        = string
}

variable "app_team_access" {
  description = "kubectl access of AppTeam-<env>-Role: admin, edit or view"
  type        = string
}

variable "cicd_access" {
  description = "kubectl access of FinTech-CI-CD-Deployer-<env>: admin, edit or view"
  type        = string
}

############################ Node groups ############################
variable "node_color" {
  description = "Which node groups to create: blue, green, or both"
  type        = string
}

variable "data_plane_blue" {
  description = "Name of the Core Services Blue node group"
  type        = string
}

variable "data_plane_green" {
  description = "Name of the Core Services Green node group"
  type        = string
}

variable "ml_data_plane_blue" {
  description = "Name of the Machine Learning Blue node group"
  type        = string
}

variable "ml_data_plane_green" {
  description = "Name of the Machine Learning Green node group"
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types of the worker nodes"
  type        = list(string)
}

variable "core_blue_node_count" {
  description = "Number of nodes in the Core Services Blue node group"
  type        = number
}

variable "standby_node_count" {
  description = "Number of nodes in Core Green, ML Blue and ML Green (0 = none)"
  type        = number
}

variable "node_max_size" {
  description = "Maximum nodes per node group (Cluster Autoscaler upper limit)"
  type        = number
}

############################ Cluster Autoscaler ############################
variable "cluster_autoscaler_chart_version" {
  description = "Version of the cluster-autoscaler Helm chart"
  type        = string
}

variable "cluster_autoscaler_image_tag" {
  description = "Cluster Autoscaler image tag; must match the Kubernetes minor version (e.g. v1.36.x for 1.36)"
  type        = string
}