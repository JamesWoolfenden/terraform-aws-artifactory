#IAM user for S3
resource "aws_iam_user" "s3" {
  name = "s3-access"
}

#IAM access key for S3
#TODO This is awful
resource "aws_iam_access_key" "s3" {
  user = aws_iam_user.s3.name
}


#IAM Policy
#TODO Restrict to what is actuallyu required
resource "aws_iam_user_policy" "lb_ro" {
  #checkov:skip=CKV_AWS_40: "Ensure IAM policies are attached only to groups or roles (Reducing access management complexity may in-turn reduce opportunity for a principal to inadvertently receive or retain excessive privileges.)"
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
