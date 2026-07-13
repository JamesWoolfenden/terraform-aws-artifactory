variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where Artifactory will be deployed"

  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "vpc_id must be a non-empty string."
  }
}

variable "vpc_cidr" {
  type        = list(string)
  description = "CIDR block(s) for the default VPC Artifactory is deployed into"

  validation {
    condition     = alltrue([for c in var.vpc_cidr : can(cidrhost(c, 0))])
    error_message = "Each entry in vpc_cidr must be a valid CIDR block."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs Artifactory, its load balancer, and its database are deployed into"

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "The subnet_ids list must not be empty."
  }
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
  description = "EC2 instance type for the Artifactory server"
  default     = "m4.xlarge"

  validation {
    condition     = length(trimspace(var.instance_type)) > 0
    error_message = "The instance_type must not be empty."
  }
}
