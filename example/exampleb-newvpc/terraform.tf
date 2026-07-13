# holden:ignore:HLD_TF_004: generic public example - must not force every
# consumer onto a specific backend/state bucket they don't own
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.54.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.9.0"
    }
  }
  required_version = ">= 1.5"
}
