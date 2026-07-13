# holden:ignore:HLD_TF_004
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.8.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.43.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
    }
  }
  required_version = ">=1.5"
}
