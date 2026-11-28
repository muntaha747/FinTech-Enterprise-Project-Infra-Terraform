# main.tf: one KMS key (+ a friendly alias) that encrypts databases and S3 buckets.

resource "aws_kms_key" "FinTech_Prod_Key" {
  description             = var.description
  enable_key_rotation     = var.enable_key_rotation     # AWS rotates the key every year
  deletion_window_in_days = var.deletion_window_in_days # waiting days before a deleted key is gone
  multi_region            = var.multi_region            # usable in another region for disaster recovery

  tags = merge(var.tags, {
    Name        = "fintech-${var.environment}-${var.key_name}-kms"
    Environment = var.environment
  })
}

# Alias = a readable name for the key, e.g. alias/fintech-prod-data
resource "aws_kms_alias" "friendly_key_name" {
  name          = "alias/fintech-${var.environment}-${var.key_name}"
  target_key_id = aws_kms_key.FinTech_Prod_Key.key_id
}
