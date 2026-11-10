data "aws_caller_identity" "current" {}

# Dedicated sink for S3 server access logs delivered from aws_s3_bucket.b
# and aws_s3_bucket.alb_logs. Not logged to itself - a log bucket logging
# its own access is not actionable and AWS access logging cannot target the
# same bucket it logs anyway without risking a delivery loop.
# holden:ignore:HLD_AWS_005,HLD_AWS_144: this is the log-delivery target itself; logging to itself risks a delivery loop
# holden:ignore:HLD_AWS_009: versioning is enabled via aws_s3_bucket_versioning.access_logs below;
# this check only recognizes the pre-provider-v4 inline versioning{} block
# holden:ignore:HLD_AWS_310: log bucket with 90-day expiry; Object Lock can only be set at creation and would force bucket replacement
resource "aws_s3_bucket" "access_logs" {
  bucket = "${var.bucket_name}-access-logs"
}

resource "aws_s3_bucket_versioning" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket                  = aws_s3_bucket.access_logs.id
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

# holden:ignore:HLD_AWS_282: S3 server-access-log target bucket - S3 log delivery supports only SSE-S3 (AES256) on the destination, not SSE-KMS (it silently drops records)
resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    id     = "expire-old-access-logs"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3LogDelivery"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.access_logs.arn}/*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = [
              aws_s3_bucket.b.arn,
              aws_s3_bucket.alb_logs.arn
            ]
          }
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [aws_s3_bucket.access_logs.arn, "${aws_s3_bucket.access_logs.arn}/*"]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_logging" "b" {
  bucket = aws_s3_bucket.b.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "s3-access/artifactory-storage/"
}

resource "aws_s3_bucket_logging" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "s3-access/alb-logs/"
}
