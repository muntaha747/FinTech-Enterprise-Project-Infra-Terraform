# loki.tf: Loki stores logs in S3. Grafana reads them.
# The bucket itself is created by the S3 stack (var.loki_bucket_name).

############################ Loki: IAM role for its pod (IRSA) ############################
resource "aws_iam_role" "loki" {
  name = "${var.cluster_name}-Loki-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = var.oidc_provider_arn }
      Condition = {
        StringEquals = {
          "${local.oidc_issuer_host}:sub" = "system:serviceaccount:${var.namespace}:loki"
          "${local.oidc_issuer_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-Loki-Role" })
}

# Read and write only the Loki bucket
resource "aws_iam_role_policy" "loki" {
  name = "${var.cluster_name}-Loki-S3"
  role = aws_iam_role.loki.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.loki_bucket_name}"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "arn:aws:s3:::${var.loki_bucket_name}/*"
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

############################ Loki ############################
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = var.chart_versions.loki
  namespace  = kubernetes_namespace_v1.platform_tools.metadata[0].name
  timeout    = 900

  values = [yamlencode({
    deploymentMode = "SingleBinary" # one pod: simple; switch to SimpleScalable when logs grow

    loki = {
      auth_enabled = false
      commonConfig = { replication_factor = 1 }
      schemaConfig = {
        configs = [{
          from         = "2024-01-01"
          store        = "tsdb"
          object_store = "s3"
          schema       = "v13"
          index        = { prefix = "loki_index_", period = "24h" }
        }]
      }
      storage = {
        type        = "s3"
        bucketNames = { chunks = var.loki_bucket_name, ruler = var.loki_bucket_name, admin = var.loki_bucket_name }
        s3          = { region = var.region }
      }
    }

    serviceAccount = {
      name        = "loki"
      annotations = { "eks.amazonaws.com/role-arn" = aws_iam_role.loki.arn }
    }

    singleBinary = {
      replicas     = 1
      nodeSelector = local.core_nodes
      persistence  = { storageClass = "gp3" }
    }
    gateway = { nodeSelector = local.core_nodes }

    # Not used in SingleBinary mode
    read         = { replicas = 0 }
    write        = { replicas = 0 }
    backend      = { replicas = 0 }
    chunksCache  = { enabled = false }
    resultsCache = { enabled = false }
    lokiCanary   = { enabled = false }
    test         = { enabled = false }
  })]

  depends_on = [aws_iam_role_policy.loki, kubernetes_storage_class_v1.gp3]
}
