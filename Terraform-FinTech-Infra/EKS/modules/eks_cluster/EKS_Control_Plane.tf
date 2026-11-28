# EKS_Control_Plane.tf: the Kubernetes control plane and who may log in to it.

############################ KMS key for Kubernetes Secrets ############################
# Without it, Secrets are only base64 in etcd. With it, they are encrypted.
resource "aws_kms_key" "eks_secrets" {
  # checkov:skip=CKV2_AWS_64: Default key policy is what EKS expects
  description             = "Encrypts Kubernetes Secrets of ${var.cluster_name}"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window_days
  tags                    = merge(local.common_tags, { Name = "${var.cluster_name}-secrets-key" })
}

############################ Control plane logs ############################
# Audit log = who did what in the cluster. Kept for var.cluster_log_retention_days.
resource "aws_cloudwatch_log_group" "eks_cluster" {
  # checkov:skip=CKV_AWS_158: Default CloudWatch encryption for now
  name              = "/aws/eks/${var.cluster_name}/cluster" # EKS always writes to this exact name
  retention_in_days = var.cluster_log_retention_days
  tags              = merge(local.common_tags, { Name = "${var.cluster_name}-control-plane-logs" })
}

############################ EKS cluster ############################
resource "aws_eks_cluster" "eks_control_plane" {
  # checkov:skip=CKV_AWS_39: Public endpoint needed by GitHub runners and the engineer's laptop
  # checkov:skip=CKV_AWS_38: GitHub runners have no fixed IPs; IAM still protects the API
  # checkov:skip=CKV_AWS_339: Checkov's version list is older than EKS 1.36
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.eks_fintech_cluster_role.arn
  version                       = var.cluster_version
  bootstrap_self_managed_addons = true
  enabled_cluster_log_types     = var.cluster_log_types

  # Control plane network cards go into the private subnets
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [var.cluster_security_group_id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  # Logins use EKS access entries (no aws-auth ConfigMap). The creator becomes admin.
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Encrypt Kubernetes Secrets with the KMS key above
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
  }

  tags = merge(local.common_tags, { Name = "EKS-Control-Plane-${var.cluster_name}" })

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment,
    aws_cloudwatch_log_group.eks_cluster, # must exist first, or EKS makes its own
  ]
}

############################ Extra cluster admins ############################
# Everyone in var.cluster_admin_arns gets cluster-admin, except the creator (EKS already did that).

data "aws_caller_identity" "current_aws_user" {}

# Turns the caller's session ARN into the real role/user ARN
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current_aws_user.arn
}

locals {
  extra_cluster_admins = toset([
    for arn in var.cluster_admin_arns : arn if arn != data.aws_iam_session_context.current.issuer_arn
  ])
}

# 1. Let each admin into the cluster (for_each: removing one admin does not touch the others)
resource "aws_eks_access_entry" "cluster_admins" {
  for_each      = local.extra_cluster_admins
  cluster_name  = aws_eks_cluster.eks_control_plane.name
  principal_arn = each.value
  type          = "STANDARD"
}

# 2. Give each admin full cluster-admin rights
resource "aws_eks_access_policy_association" "cluster_admins" {
  for_each      = local.extra_cluster_admins
  cluster_name  = aws_eks_cluster.eks_control_plane.name
  principal_arn = aws_eks_access_entry.cluster_admins[each.key].principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

############################ DevOps engineer access ############################
# The DevOps role (IAM.tf) is mapped to Kubernetes groups; RBAC inside the cluster decides its rights
resource "aws_eks_access_entry" "hassan_devops_engineer_entry" {
  cluster_name      = aws_eks_cluster.eks_control_plane.name
  principal_arn     = aws_iam_role.hassan_iam_role.arn
  type              = "STANDARD"
  kubernetes_groups = var.devops_kubernetes_groups
}
