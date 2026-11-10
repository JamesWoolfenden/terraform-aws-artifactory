resource "aws_iam_instance_profile" "art" {
  name = var.profile_name
  role = aws_iam_role.art.name
}

# holden:ignore:HLD_AWS_316: EC2 instance-profile trust - aws:SourceAccount/aws:SourceArn are not set for EC2 role assumption, so the condition cannot be applied
resource "aws_iam_role" "art" {
  name                 = var.profile_name
  path                 = "/"
  max_session_duration = 3600

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "art" {
  name = var.profile_name
  role = aws_iam_role.art.id

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${aws_s3_bucket.b.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["${aws_s3_bucket.b.arn}/*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Resource": ["${var.kms_key}"]
    },
    {
      "Effect": "Allow",
      "Action": ["ssm:GetParameter"],
      "Resource": [
        "${aws_ssm_parameter.db_password.arn}",
        "${aws_ssm_parameter.master_key.arn}"
      ]
    }
  ]
}
EOF
}
