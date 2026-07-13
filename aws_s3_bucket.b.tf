# holden:ignore:HLD_AWS_009,HLD_AWS_005: versioning and logging are enabled via the
# modern aws_s3_bucket_versioning/aws_s3_bucket_logging companion resources below;
# this check only recognizes the pre-provider-v4 inline versioning{}/logging{} blocks
# holden:ignore:HLD_AWS_153: lifecycle managed by Artifactory directly, not via S3 lifecycle rules
# checkov:skip=CKV_AWS_144: not required for this use case
# checkov:skip=CKV2_AWS_61: lifecycle managed by Artifactory directly, not via S3 lifecycle rules
# checkov:skip=CKV2_AWS_62: event notifications not required for Artifactory binary storage bucket
resource "aws_s3_bucket" "b" {
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
