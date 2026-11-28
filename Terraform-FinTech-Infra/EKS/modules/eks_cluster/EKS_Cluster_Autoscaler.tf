# EKS_Cluster_Autoscaler.tf: adds nodes when pods are waiting, removes empty nodes.
# Steps: 1. IAM policy (what it may do)  2. IAM role (only its pod may use it)
#        3. attach policy to role         4. install it with Helm

locals {
  # OIDC issuer URL without "https://", the form IAM trust conditions need
  oidc_issuer_host = replace(aws_eks_cluster.eks_control_plane.identity[0].oidc[0].issuer, "https://", "")
  account_id       = data.aws_caller_identity.current_aws_user.account_id

  cluster_autoscaler_service_account = "cluster-autoscaler"
}

############################ 1. IAM policy ############################
# Read anything, but resize ONLY this cluster's node groups (tagged by EKS).
resource "aws_iam_policy" "cluster_autoscaler" {
  name = "${var.cluster_name}-Cluster-Autoscaler-Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadOnly"
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
        ]
        Resource = "*"
      },
      {
        # Read node group labels/taints, needed to scale a group up from 0 nodes
        Sid      = "ReadOwnNodeGroups"
        Effect   = "Allow"
        Action   = ["eks:DescribeNodegroup"]
        Resource = "arn:aws:eks:${var.region}:${local.account_id}:nodegroup/${var.cluster_name}/*/*"
      },
      {
        Sid    = "ScaleOwnNodeGroups"
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
        ]
        Resource = "arn:aws:autoscaling:${var.region}:${local.account_id}:autoScalingGroup:*:autoScalingGroupName/*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
          }
        }
      },
    ]
  })

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-Cluster-Autoscaler-Policy" })
}

############################ 2. IAM role ############################
# Only the "cluster-autoscaler" service account in kube-system of THIS cluster may use it.
resource "aws_iam_role" "cluster_autoscaler" {
  name = "${var.cluster_name}-Cluster-Autoscaler-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = aws_iam_openid_connect_provider.eks_oidc.arn }
      Condition = {
        StringEquals = {
          "${local.oidc_issuer_host}:sub" = "system:serviceaccount:kube-system:${local.cluster_autoscaler_service_account}"
          "${local.oidc_issuer_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-Cluster-Autoscaler-Role" })
}

############################ 3. Attach policy to role ############################
resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

############################ 4. Install with Helm ############################
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = var.cluster_autoscaler_chart_version
  atomic     = true # a failed install is removed, so the next run can retry

  values = [yamlencode({
    image         = { tag = var.cluster_autoscaler_image_tag } # must match the Kubernetes version
    awsRegion     = var.region
    autoDiscovery = { clusterName = aws_eks_cluster.eks_control_plane.name } # finds node groups by tag
    nodeSelector  = { role = "core" }

    rbac = {
      serviceAccount = {
        create      = true
        name        = local.cluster_autoscaler_service_account
        annotations = { "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn } # IRSA
      }
    }

    extraArgs = {
      balance-similar-node-groups = true  # keep blue and green about the same size
      skip-nodes-with-system-pods = false # a node with kube-system pods can still be removed
    }
  })]

  # Needs its IAM permissions and at least one node to run on
  depends_on = [
    aws_iam_role_policy_attachment.cluster_autoscaler,
    aws_eks_node_group.core_data_plane_blue,
  ]
}
