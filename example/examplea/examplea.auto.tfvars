common_tags = {
  createdby = "Terraform"
  module    = "terraform-aws-artifactory"
}
vpc_id             = "vpc-0e2e925de622375b5"
vpc_cidr           = ["10.0.0.0/21"]
subnet_ids         = ["subnet-05808ec64faaa18ba", "subnet-0b57d1924ea055989", "subnet-05f8f3c120238ca8d"]
ssl_certificate_id = "arn:aws:acm:eu-west-2:680235478471:certificate/772b2402-5d4a-457f-829c-02550c8c9244"
zone_id            = "Z0613304D03LG1SU5BI"
record             = "artifact.freebeer.site"
