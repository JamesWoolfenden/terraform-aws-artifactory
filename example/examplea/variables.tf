variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where Artifactory will be deployed"

  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "vpc_id must be a non-empty string."
  }
}

variable "vpc_cidr" {
  type = list(any)
}

variable "subnet_ids" {
  type = list(any)
}

variable "ssl_certificate_id" {
  type        = string
  description = "The ARN of the SSL certificate for Artifactory HTTPS access"

  validation {
    condition     = length(trimspace(var.ssl_certificate_id)) > 0
    error_message = "ssl_certificate_id must be a non-empty string."
  }
}

variable "zone_id" {
  type        = string
  description = "The Route53 hosted zone ID for the DNS record"

  validation {
    condition     = length(trimspace(var.zone_id)) > 0
    error_message = "zone_id must be a non-empty string."
  }
}

variable "record" {
  type        = string
  description = "The DNS record name for the Artifactory instance"

  validation {
    condition     = length(trimspace(var.record)) > 0
    error_message = "record must be a non-empty string."
  }
}

variable "instance_type" {
  type        = string
  description = "The size/type of your instance"
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.nano", "t3.micro", "t3.small", "t3.medium", "t3.large"], var.instance_type)
    error_message = "instance_type must be a supported t3 instance type."
  }
}

locals {
  instance_type = var.instance_type
}
