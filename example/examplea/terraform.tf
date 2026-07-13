# holden:ignore:HLD_TF_004
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.9.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.54.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.3.0"
    }
  }
  required_version = ">=1.5"
}
