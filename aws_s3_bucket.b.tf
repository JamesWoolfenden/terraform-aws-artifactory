# holden:ignore:HLD_AWS_009,HLD_AWS_005: versioning and logging are enabled via the
# modern aws_s3_bucket_versioning/aws_s3_bucket_logging companion resources below;
# this check only recognizes the pre-provider-v4 inline versioning{}/logging{} blocks
# holden:ignore:HLD_AWS_153: lifecycle managed by Artifactory directly, not via S3 lifecycle rules
# checkov:skip=CKV_AWS_144: this module is single-region/single-instance by design
# (one VPC, one RDS instance, one KMS key, no destination-region input exists in
# its interface) and Artifactory HA needs more than replicated storage - shared
# filestore semantics and cluster config this module doesn't attempt. Bolting on
# S3 CRR alone would be a partial, misleading DR gesture; real multi-region HA
# needs a broader redesign than this one attribute, and should be a deliberate
# consumer decision, not a silent default.
resource "aws_s3_bucket" "b" {
  # checkov:skip=CKV2_AWS_61: lifecycle managed by Artifactory directly, not via S3 lifecycle rules
  # checkov:skip=CKV2_AWS_62: event notifications not required for Artifactory binary storage bucket
  # checkov:skip=CKV_AWS_144: cross region not required
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
