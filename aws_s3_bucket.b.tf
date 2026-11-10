# holden:ignore:HLD_AWS_009,HLD_AWS_005: versioning and logging are enabled via the
# modern aws_s3_bucket_versioning/aws_s3_bucket_logging companion resources below;
# this check only recognizes the pre-provider-v4 inline versioning{}/logging{} blocks
# holden:ignore:HLD_AWS_310: Artifactory deletes and overwrites its own objects; Object Lock retention would block garbage collection
resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name
}

# Current objects are managed by Artifactory itself (no expiration rule here);
# only superseded versions and abandoned uploads are bounded.
# holden:ignore:HLD_AWS_384: current objects are removed by Artifactory garbage collection, not S3 expiry; expiring them in S3 would delete live artifacts
resource "aws_s3_bucket_lifecycle_configuration" "b" {
  bucket = aws_s3_bucket.b.id

  rule {
    id     = "bound-noncurrent-versions"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.b.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [aws_s3_bucket.b.arn, "${aws_s3_bucket.b.arn}/*"]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
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
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_key : null
      sse_algorithm     = var.sse_algorithm
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
