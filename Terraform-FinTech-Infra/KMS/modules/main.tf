resource "aws_kms_key" "FinTech_Prod_Key" {
  description             = "This is the resource to create AWS KMS KEY for the Databases and S3 buckets"
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
  multi_region            = var.multi_region
  tags = merge(var.tags, {
    Name        = "fintech-${var.environment}-${var.key_name}-kms"
    Environment = var.environment
  })
}

resource "aws_kms_alias" "friendly_key_name" {
  name          = "alias/fintech-${var.environment}-${var.key_name}"
  target_key_id = aws_kms_key.FinTech_Prod_Key.key_id
}


