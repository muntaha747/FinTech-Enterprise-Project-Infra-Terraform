# EKS_Addons.tf: AWS-managed add-ons that every cluster needs.
# AWS installs and upgrades these for us (no Helm needed).

############################ Networking add-ons ############################
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.eks_control_plane.name
  addon_name                  = "vpc-cni" # gives every pod an IP from the VPC
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.eks_control_plane.name
  addon_name                  = "kube-proxy" # routes Service traffic to pods
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks_control_plane.name
  addon_name                  = "coredns" # DNS inside the cluster
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.core_data_plane_blue] # needs nodes to run on
}

############################ Metrics Server ############################
# Feeds `kubectl top` and the HPA (pod autoscaling)
resource "aws_eks_addon" "metrics_server" {
  cluster_name                = aws_eks_cluster.eks_control_plane.name
  addon_name                  = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.core_data_plane_blue]
}

############################ EBS CSI driver (disks for pods) ############################
# Prometheus, Grafana and Loki store data on EBS disks. This driver creates them.

# Role the driver's pod uses (IRSA)
resource "aws_iam_role" "ebs_csi" {
  name = "${var.cluster_name}-EBS-CSI-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = aws_iam_openid_connect_provider.eks_oidc.arn }
      Condition = {
        StringEquals = {
          "${local.oidc_issuer_host}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          "${local.oidc_issuer_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-EBS-CSI-Role" })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.eks_control_plane.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi,
    aws_eks_node_group.core_data_plane_blue,
  ]
}
