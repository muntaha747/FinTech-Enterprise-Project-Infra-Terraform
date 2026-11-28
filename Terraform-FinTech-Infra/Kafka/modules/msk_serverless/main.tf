# main.tf: one Amazon MSK Serverless (Kafka) cluster in the App VPC.
#   - Sits in private subnets 1, 2 and 3 of the App VPC (one per AZ), close to EKS.
#   - Clients log in with IAM (port 9098). No passwords.

locals {
  common_tags = merge(var.tags, { Environment = var.environment })
}

############################ Security group ############################
# Kafka port 9098 (IAM login) from inside the App VPC only
resource "aws_security_group" "kafka" {
  name        = "${var.cluster_name}-sg"
  description = "Kafka (MSK Serverless) from the App VPC only"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { Name = "${var.cluster_name}-sg" })

  ingress {
    description = "Kafka with IAM login (9098) from the App VPC"
    from_port   = 9098
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "Outbound inside the App VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }
}

############################ MSK Serverless cluster ############################
resource "aws_msk_serverless_cluster" "kafka" {
  cluster_name = var.cluster_name

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.kafka.id]
  }

  # Log in with IAM (the only option MSK Serverless supports)
  client_authentication {
    sasl {
      iam {
        enabled = true
      }
    }
  }

  tags = merge(local.common_tags, { Name = var.cluster_name })
}
