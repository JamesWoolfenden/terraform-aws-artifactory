


#IAM user for S3
resource "aws_iam_user" "s3" {
  name = "s3-access"
}

#IAM access key for S3
resource "aws_iam_access_key" "s3" {
  user = aws_iam_user.s3.name
}

# S3 bucket
resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name
  acl    = "private"
}

#IAM Policy
resource "aws_iam_user_policy" "lb_ro" {
  user = aws_iam_user.s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
      "arn:aws:s3:::${aws_s3_bucket.b.id}/*",
      "arn:aws:s3:::${aws_s3_bucket.b.id}"
      ]
    }
  ]
}
EOF
}
