variable "instance" {
  description = "EC2 instance configuration for the Artifactory launch template"
  type = object({
    key_name           = optional(string, "jfrog")
    volume_size        = optional(number, 250)
    instance_type      = string
    extra_java_options = optional(string, "-server -Xms2g -Xmx14g -Xss256k -XX:+UseG1GC -XX:OnOutOfMemoryError=\\\\\\\"kill -9 %p\\\\\\\"")
  })

  validation {
    condition = (
      length(trimspace(var.instance.key_name)) > 0 &&
      var.instance.volume_size > 0 &&
      length(trimspace(var.instance.instance_type)) > 0 &&
      length(trimspace(var.instance.extra_java_options)) > 0
    )
    error_message = "instance.key_name, instance.instance_type, and instance.extra_java_options must not be empty, and instance.volume_size must be greater than 0."
  }
}

variable "bucket_name" {
  type        = string
  description = "AWS S3 Bucket name"
  validation {
    condition     = length(trimspace(var.bucket_name)) > 0
    error_message = "The bucket_name must not be empty."
  }
}

variable "database" {
  description = "RDS database configuration for Artifactory"
  sensitive   = true
  type = object({
    name                = optional(string, "artdb")
    user                = optional(string, "artifactory")
    password            = string
    instance_class      = optional(string, "db.t2.small")
    allocated_storage   = optional(string, "5")
    storage_type        = optional(string, "gp2")
    engine              = optional(string, "mysql")
    engine_version      = optional(string, "5.5")
    skip_final_snapshot = optional(bool, true)
    monitoring_interval = optional(number, 30)
    monitoring_role_arn = string
  })

  validation {
    condition = (
      length(trimspace(var.database.name)) > 0 &&
      length(trimspace(var.database.user)) > 0 &&
      length(trimspace(var.database.password)) > 0 &&
      length(trimspace(var.database.instance_class)) > 0 &&
      can(regex("^[0-9]+$", var.database.allocated_storage)) &&
      tonumber(var.database.allocated_storage) > 0 &&
      contains(["mysql", "postgres", "mariadb", "oracle", "sqlserver"], var.database.engine) &&
      contains([0, 1, 5, 10, 15, 30, 60], var.database.monitoring_interval) &&
      length(trimspace(var.database.monitoring_role_arn)) > 0
    )
    error_message = "Check database.name/user/password/instance_class are non-empty, allocated_storage is a positive integer, engine is one of mysql/postgres/mariadb/oracle/sqlserver, monitoring_interval is one of 0/1/5/10/15/30/60, and monitoring_role_arn is set."
  }
}

variable "master_key" {
  type        = string
  description = "Master key for Artifactory cluster. Generate master.key using command '$openssl rand -hex 16'"
  sensitive   = true

  validation {
    condition     = length(trimspace(var.master_key)) > 0
    error_message = "The master_key must not be empty."
  }
}

variable "artifactory_server_name" {
  type        = string
  description = "Provide artifactory server name to be used in Nginx. e.g artifactory for artifactory.jfrog.team"
  default     = "artifactory"

  validation {
    condition     = length(trimspace(var.artifactory_server_name)) > 0
    error_message = "The artifactory_server_name must not be empty."
  }
}

variable "load_balancer" {
  description = "Load balancer name and TLS certificate for the Artifactory endpoint"
  type = object({
    name               = optional(string, "artifactoryelb")
    ssl_certificate_id = string
  })

  validation {
    condition     = length(trimspace(var.load_balancer.name)) > 0 && length(trimspace(var.load_balancer.ssl_certificate_id)) > 0
    error_message = "load_balancer.name and load_balancer.ssl_certificate_id must not be empty."
  }
}

variable "artifactory_sg_name" {
  type        = string
  default     = "artifactory_sg"
  description = "Name for the Artifactory instance security group"

  validation {
    condition     = length(trimspace(var.artifactory_sg_name)) > 0
    error_message = "The artifactory_sg_name must not be empty."
  }
}

variable "sse_algorithm" {
  description = "The type of encryption algorithm to use"
  type        = string
  default     = "aws:kms"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "The sse_algorithm must be one of: AES256, aws:kms."
  }
}

variable "network" {
  description = "VPC and subnet configuration for Artifactory, its load balancer, and its database"
  type = object({
    vpc_id         = string
    vpc_cidr       = list(string)
    subnet_ids     = list(string)
    alb_subnet_ids = optional(list(string), [])
    access_cidr    = list(string)
    ssh_access     = list(string)

    # No default: whether instances get public IPs is a real security
    # tradeoff (false requires subnet_ids to be private with NAT egress for
    # package installation at boot) that every caller must decide explicitly
    # rather than silently inherit.
    associate_public_ip = bool
  })

  validation {
    condition = (
      length(trimspace(var.network.vpc_id)) > 0 &&
      length(var.network.subnet_ids) > 0 &&
      alltrue([for c in var.network.vpc_cidr : can(cidrhost(c, 0))]) &&
      alltrue([for c in var.network.access_cidr : can(cidrhost(c, 0))]) &&
      alltrue([for c in var.network.ssh_access : can(cidrhost(c, 0))]) &&
      alltrue([for s in var.network.alb_subnet_ids : length(trimspace(s)) > 0])
    )
    error_message = "network.vpc_id must not be empty, network.subnet_ids must not be empty, and vpc_cidr/access_cidr/ssh_access must contain only valid CIDR blocks."
  }
}

variable "profile_name" {
  type        = string
  default     = "artifactory"
  description = "Instance profile name"

  validation {
    condition     = length(trimspace(var.profile_name)) > 0
    error_message = "The profile_name must not be empty."
  }
}

variable "dns" {
  description = "Route53 DNS configuration for the Artifactory endpoint"
  type = object({
    zone_id = string
    record  = string
  })

  validation {
    condition     = length(trimspace(var.dns.zone_id)) > 0 && length(trimspace(var.dns.record)) > 0
    error_message = "dns.zone_id and dns.record must not be empty."
  }
}

variable "autoscaling_group_name" {
  type        = string
  description = "artifactory autoscaling group"
  default     = "artifactory autoscaling group"

  validation {
    condition     = length(trimspace(var.autoscaling_group_name)) > 0
    error_message = "The autoscaling_group_name must not be empty."
  }
}

variable "kms_key" {
  type        = string
  description = "KMS key ARN or alias for encrypting resources"
  sensitive   = true

  validation {
    condition     = length(trimspace(var.kms_key)) > 0
    error_message = "The kms_key must not be empty."
  }
}
