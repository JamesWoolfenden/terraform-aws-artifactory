variable "vpc_cidr" {
  type        = list(string)
  description = "CIDR block(s) for the VPC created by this example"
  default     = ["10.0.0.0/16"]

  validation {
    condition     = alltrue([for c in var.vpc_cidr : can(cidrhost(c, 0))])
    error_message = "Each entry in vpc_cidr must be a valid CIDR block."
  }
}

variable "bucket_name" {
  type        = string
  description = "AWS S3 bucket name for Artifactory binary storage"

  validation {
    condition     = length(trimspace(var.bucket_name)) > 0
    error_message = "The bucket_name must not be empty."
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

variable "ssh_access" {
  type        = list(string)
  description = "CIDR blocks allowed SSH access to the Artifactory instance"

  validation {
    condition     = alltrue([for c in var.ssh_access : can(cidrhost(c, 0))])
    error_message = "Each entry in ssh_access must be a valid CIDR block."
  }
}

variable "access_cidr" {
  type        = list(string)
  description = "CIDR blocks allowed HTTPS access to the load balancer"

  validation {
    condition     = alltrue([for c in var.access_cidr : can(cidrhost(c, 0))])
    error_message = "Each entry in access_cidr must be a valid CIDR block."
  }
}

variable "ssl_certificate_id" {
  type        = string
  description = "ACM certificate ARN for the load balancer's HTTPS listener"

  validation {
    condition     = length(trimspace(var.ssl_certificate_id)) > 0
    error_message = "The ssl_certificate_id must not be empty."
  }
}

variable "zone_id" {
  type        = string
  description = "The Route53 hosted zone ID for the DNS record"

  validation {
    condition     = length(trimspace(var.zone_id)) > 0
    error_message = "The zone_id must not be empty."
  }
}

variable "record" {
  type        = string
  description = "The DNS record name for the Artifactory instance"

  validation {
    condition     = length(trimspace(var.record)) > 0
    error_message = "The record must not be empty."
  }
}
