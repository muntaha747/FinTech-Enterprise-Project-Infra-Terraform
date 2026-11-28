# EKS_Team_Access.tf: lets the team roles from the IAM stack use kubectl on this cluster.
#   admin = full control | edit = deploy and change apps | view = read only

locals {
  access_policies = {
    admin = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    edit  = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
    view  = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  }
}

# 1. Let each team role into the cluster (for_each: removing one role does not touch the others)
resource "aws_eks_access_entry" "team_roles" {
  for_each      = var.team_roles
  cluster_name  = aws_eks_cluster.eks_control_plane.name
  principal_arn = each.value.role_arn
  type          = "STANDARD"
  tags          = merge(local.common_tags, { Name = each.key })
}

# 2. Give each team role its access level, in every namespace
resource "aws_eks_access_policy_association" "team_roles" {
  for_each      = var.team_roles
  cluster_name  = aws_eks_cluster.eks_control_plane.name
  principal_arn = aws_eks_access_entry.team_roles[each.key].principal_arn
  policy_arn    = local.access_policies[each.value.access]

  access_scope {
    type = "cluster"
  }
}
