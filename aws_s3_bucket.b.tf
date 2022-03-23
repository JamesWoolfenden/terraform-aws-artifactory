# S3 bucket

resource "aws_s3_bucket" "b" {
  # tfsec:ignore:AWS002
  # checkov:skip=CKV_AWS_18: no logging req
  # checkov:skip=CKV_AWS_52: no mfa req
  # checkov:skip=CKV_AWS_144: Not required
  # checkov:skip=CKV_AWS_19:v4 legacy
  # checkov:skip=CKV_AWS_145:v4 legacy
  # checkov:skip=CKV_AWS_21:v4 legacy
  # checkov:skip=CKV2_AWS_41:no logging req
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "b" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "b" {
  bucket = aws_s3_bucket.b.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "b" {
  bucket = aws_s3_bucket.b.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "b" {
  bucket                  = aws_s3_bucket.b.id
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}
