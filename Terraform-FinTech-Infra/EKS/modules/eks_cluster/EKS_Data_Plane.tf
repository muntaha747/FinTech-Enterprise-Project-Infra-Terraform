# EKS_Data_Plane.tf: the worker nodes. Four node groups:
#   Core Blue  / Core Green -> normal application pods
#   ML Blue    / ML Green   -> ML pods only (tainted)
#
# var.node_color decides which colour is created: "blue", "green" or "both".
#   count = 1 -> created, count = 0 -> not created

locals {
  create_blue  = var.node_color == "blue" || var.node_color == "both"
  create_green = var.node_color == "green" || var.node_color == "both"
}

############################ Core Blue ############################
resource "aws_eks_node_group" "core_data_plane_blue" {
  count           = local.create_blue ? 1 : 0
  cluster_name    = aws_eks_cluster.eks_control_plane.name
  node_group_name = var.data_plane_blue
  node_role_arn   = aws_iam_role.eks_fintech_worker_node_role.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types

  labels = { role = "core" }

  scaling_config {
    desired_size = var.core_blue_node_count
    min_size     = var.core_blue_node_count
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = var.node_max_unavailable
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size] # Cluster Autoscaler owns this
  }

  tags = merge(local.common_tags, { Name = var.data_plane_blue })

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]
}

############################ Core Green ############################
resource "aws_eks_node_group" "core_data_plane_green" {
  count           = local.create_green ? 1 : 0
  cluster_name    = aws_eks_cluster.eks_control_plane.name
  node_group_name = var.data_plane_green
  node_role_arn   = aws_iam_role.eks_fintech_worker_node_role.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types

  labels = { role = "core" }

  scaling_config {
    desired_size = var.standby_node_count
    min_size     = var.standby_node_count
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = var.node_max_unavailable
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size] # Cluster Autoscaler owns this
  }

  tags = merge(local.common_tags, { Name = var.data_plane_green })

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]
}

############################ ML Blue ############################
resource "aws_eks_node_group" "ml_data_plane_blue" {
  count           = local.create_blue ? 1 : 0
  cluster_name    = aws_eks_cluster.eks_control_plane.name
  node_group_name = var.ml_data_plane_blue
  node_role_arn   = aws_iam_role.eks_fintech_worker_node_role.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types

  labels = { role = "ml" }

  scaling_config {
    desired_size = var.standby_node_count
    min_size     = var.standby_node_count
    max_size     = var.node_max_size
  }

  # Only ML pods may run here
  taint {
    key    = var.ml_taint_key
    value  = var.ml_taint_value
    effect = "NO_SCHEDULE"
  }

  update_config {
    max_unavailable = var.node_max_unavailable
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size] # Cluster Autoscaler owns this
  }

  tags = merge(local.common_tags, { Name = var.ml_data_plane_blue })

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]
}

############################ ML Green ############################
resource "aws_eks_node_group" "ml_data_plane_green" {
  count           = local.create_green ? 1 : 0
  cluster_name    = aws_eks_cluster.eks_control_plane.name
  node_group_name = var.ml_data_plane_green
  node_role_arn   = aws_iam_role.eks_fintech_worker_node_role.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types

  labels = { role = "ml" }

  scaling_config {
    desired_size = var.standby_node_count
    min_size     = var.standby_node_count
    max_size     = var.node_max_size
  }

  # Only ML pods may run here
  taint {
    key    = var.ml_taint_key
    value  = var.ml_taint_value
    effect = "NO_SCHEDULE"
  }

  update_config {
    max_unavailable = var.node_max_unavailable
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size] # Cluster Autoscaler owns this
  }

  tags = merge(local.common_tags, { Name = var.ml_data_plane_green })

  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]
}

############################ kubeconfig ############################
# After the cluster is created, set up kubectl on this machine
resource "terraform_data" "update_kubeconfig" {
  triggers_replace = [aws_eks_cluster.eks_control_plane.endpoint]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${aws_eks_cluster.eks_control_plane.name} --region ${var.region}"
  }

  depends_on = [aws_eks_cluster.eks_control_plane]
}
