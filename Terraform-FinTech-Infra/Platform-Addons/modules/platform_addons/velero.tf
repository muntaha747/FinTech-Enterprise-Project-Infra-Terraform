# velero.tf: Velero backs up Kubernetes objects to S3 and disks to EBS snapshots.
# The bucket itself is created by the S3 stack (var.velero_bucket_name).

############################ IAM role for the Velero pod (IRSA) ############################
resource "aws_iam_role" "velero" {
  name = "${var.cluster_name}-Velero-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = var.oidc_provider_arn }
      Condition = {
        StringEquals = {
          "${local.oidc_issuer_host}:sub" = "system:serviceaccount:${var.namespace}:velero-server"
          "${local.oidc_issuer_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-Velero-Role" })
}

# Make EBS snapshots, and read/write the backup bucket
resource "aws_iam_role_policy" "velero" {
  name = "${var.cluster_name}-Velero-Policy"
  role = aws_iam_role.velero.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes", "ec2:DescribeSnapshots", "ec2:CreateTags",
          "ec2:CreateVolume", "ec2:CreateSnapshot", "ec2:DeleteSnapshot",
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.velero_bucket_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject", "s3:PutObject", "s3:DeleteObject",
          "s3:AbortMultipartUpload", "s3:ListMultipartUploadParts",
        ]
        Resource = "arn:aws:s3:::${var.velero_bucket_name}/*"
      },
      {
        # The bucket is encrypted with our KMS key, so reading/writing needs the key too
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = var.s3_kms_key_arn
      },
    ]
  })
}

############################ Velero ############################
resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  version    = var.chart_versions.velero
  namespace  = kubernetes_namespace_v1.platform_tools.metadata[0].name

  values = [yamlencode({
    nodeSelector = local.core_nodes

    # AWS plugin: lets Velero talk to S3 and EBS
    initContainers = [{
      name         = "velero-plugin-for-aws"
      image        = "velero/velero-plugin-for-aws:${var.velero_aws_plugin_version}"
      volumeMounts = [{ mountPath = "/target", name = "plugins" }]
    }]

    configuration = {
      backupStorageLocation  = [{ name = "default", provider = "aws", bucket = var.velero_bucket_name, config = { region = var.region } }]
      volumeSnapshotLocation = [{ name = "default", provider = "aws", config = { region = var.region } }]
    }

    credentials = { useSecret = false } # uses the IAM role below, no access keys

    serviceAccount = {
      server = {
        name        = "velero-server"
        annotations = { "eks.amazonaws.com/role-arn" = aws_iam_role.velero.arn }
      }
    }

    # Back up the whole cluster every night at 02:00, keep for 30 days
    schedules = {
      nightly = {
        schedule = "0 2 * * *"
        template = { ttl = "720h", includedNamespaces = ["*"] }
      }
    }
  })]

  depends_on = [aws_iam_role_policy.velero]
}
