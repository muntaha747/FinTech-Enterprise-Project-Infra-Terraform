# main.tf: one S3 bucket per name, with versioning, encryption, no public access and a lifecycle rule.
# for_each: removing one bucket name later does not touch the other buckets.

locals {
  # Tags on every bucket
  bucket_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = var.managed_by
  })
}

############################ Buckets ############################
resource "aws_s3_bucket" "compliance_bucket" {
  # checkov:skip=CKV_AWS_144: Cross-region replication comes later (disaster recovery)
  # checkov:skip=CKV_AWS_18: Access logging comes later (with CloudTrail)
  # checkov:skip=CKV2_AWS_62: Nothing reads bucket events yet
  for_each = toset(var.bucket_names)
  bucket   = each.key
  tags     = local.bucket_tags
}

############################ Versioning ############################
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  for_each = aws_s3_bucket.compliance_bucket
  bucket   = each.value.id

  versioning_configuration {
    status = var.versioning_status
  }
}

############################ Block all public access ############################
resource "aws_s3_bucket_public_access_block" "bucket_public_access" {
  for_each = aws_s3_bucket.compliance_bucket
  bucket   = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################ Encryption (our KMS key) ############################
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  for_each = aws_s3_bucket.compliance_bucket
  bucket   = each.value.id

  rule {
    bucket_key_enabled = true # lowers KMS cost

    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.kms_key_arn # our own KMS key (from the KMS stack)
    }
  }
}

############################ Lifecycle: move old data to cheaper storage, then delete ############################
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  for_each = aws_s3_bucket.compliance_bucket
  bucket   = each.value.id

  rule {
    id     = var.lifecycle_rule_id
    status = var.lifecycle_rule_status

    filter {} # every object in the bucket

    # Delete unfinished uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_upload_days
    }

    # After 30 days -> cheaper tier
    transition {
      days          = var.infrequent_access_days
      storage_class = var.infrequent_access_storage_class
    }

    # After 180 days -> archive
    transition {
      days          = var.archive_days
      storage_class = var.archive_storage_class
    }

    # After 730 days -> delete
    expiration {
      days = var.expiration_days
    }

    # Old versions: archive, then delete
    noncurrent_version_transition {
      noncurrent_days = var.noncurrent_archive_days
      storage_class   = var.archive_storage_class
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_expiration_days
    }
  }
}
