# holden:ignore:HLD_TF_013: this is a generic public example - it must work with
# whatever credentials the consumer has configured (IAM user, SSO, CI role),
# not presume a specific assume_role/external_id setup that may not apply to them
provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = {
      createdby = "Terraform"
      module    = "terraform-aws-artifactory"
    }
  }
}
