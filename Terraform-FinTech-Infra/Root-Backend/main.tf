# main.tf: the S3 bucket that stores every other stack's state file.
# Run this FIRST, once, with local state:  export AWS_PROFILE=root-user && terraform apply

provider "aws" {
  region = "us-east-1"
}

############################ State bucket ############################
resource "aws_s3_bucket" "terraform_state" {
  bucket = "fintech-remote-backed-statefiles" # must be unique in all of AWS

  lifecycle {
    prevent_destroy = true # terraform refuses to delete this bucket
  }
}

############################ Versioning ############################
# Keeps old copies of every state file, so a broken state can be rolled back
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

############################ Encryption ############################
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

############################ Block all public access ############################
resource "aws_s3_bucket_public_access_block" "state_public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################ Clean up old versions ############################
# Old state versions are deleted after 30 days, always keeping the newest 5
resource "aws_s3_bucket_lifecycle_configuration" "state_lifecycle" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"
    filter {}

    noncurrent_version_expiration {
      noncurrent_days           = 30
      newer_noncurrent_versions = 5
    }
  }

  depends_on = [aws_s3_bucket_versioning.state_versioning]
}
