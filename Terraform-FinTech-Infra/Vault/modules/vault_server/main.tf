# main.tf: one Vault server on EC2, in a private subnet of the Ops VPC.
#   - No public IP. Reached from the EKS VPC through the Transit Gateway.
#   - Unseals itself with a KMS key (no manual unseal keys after a reboot).
#   - Logged into with SSM Session Manager (no SSH key, no port 22).

locals {
  common_tags = merge(var.tags, { Environment = var.environment })
}

############################ KMS key for auto-unseal ############################
resource "aws_kms_key" "vault_unseal" {
  description             = "Auto-unseal key for ${var.vault_name}"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = merge(local.common_tags, { Name = "${var.vault_name}-unseal-key" })
}

############################ IAM role for the EC2 instance ############################
resource "aws_iam_role" "vault" {
  name = "${var.vault_name}-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = merge(local.common_tags, { Name = "${var.vault_name}-Role" })
}

# Use the KMS key above to unseal
resource "aws_iam_role_policy" "vault_kms" {
  name = "${var.vault_name}-kms-unseal"
  role = aws_iam_role.vault.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["kms:Encrypt", "kms:Decrypt", "kms:DescribeKey"]
      Resource = aws_kms_key.vault_unseal.arn
    }]
  })
}

# Log in with SSM Session Manager instead of SSH
resource "aws_iam_role_policy_attachment" "vault_ssm" {
  role       = aws_iam_role.vault.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "vault" {
  name = "${var.vault_name}-Profile"
  role = aws_iam_role.vault.name
}

############################ Security group ############################
resource "aws_security_group" "vault" {
  name        = "${var.vault_name}-sg"
  description = "Vault API from the FinTech VPCs only"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { Name = "${var.vault_name}-sg" })

  ingress {
    description = "Vault API (8200) from the FinTech VPCs"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Outbound: package downloads, KMS, SSM"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################ EC2 instance ############################
# Latest Amazon Linux 2023 image
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_region" "current" {}

resource "aws_instance" "vault" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.vault.id]
  iam_instance_profile   = aws_iam_instance_profile.vault.name
  monitoring             = true

  # Installs and starts Vault on first boot
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    region     = data.aws_region.current.region
    kms_key_id = aws_kms_key.vault_unseal.key_id
  })

  # IMDSv2 only (stops a common credential-theft attack)
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.disk_size_gb
    encrypted   = true
  }

  tags = merge(local.common_tags, { Name = var.vault_name })

  lifecycle {
    ignore_changes = [ami] # a new AMI must not replace the Vault server by itself
  }
}
