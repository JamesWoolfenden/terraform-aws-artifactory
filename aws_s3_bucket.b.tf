# S3 bucket

resource "aws_s3_bucket" "b" {
  # tfsec:ignore:AWS002
  # checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  # checkov:skip=CKV_AWS_52: "Ensure S3 bucket has MFA delete enabled"
  # checkov:skip=CKV_AWS_144: Not required
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.sse_algorithm
      }
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
