
variable "key_name" {
  type        = string
  description = "Desired name of AWS key pair"
  default     = "jfrog"
}

variable "volume_size" {
  type        = string
  description = "Disk size for each EC2 instances"
  default     = 250
}

variable "instance_type" {
  type        = string
  description = "Artifactory EC2 instance type"
}

variable "extra_java_options" {
  type        = string
  default     = "-server -Xms2g -Xmx14g -Xss256k -XX:+UseG1GC -XX:OnOutOfMemoryError=\\\\\\\"kill -9 %p\\\\\\\""
  description = "Setting Java Memory Parameters for Artifactory. Learn about system requirements for Artifactory https://www.jfrog.com/confluence/display/RTF/System+Requirements#SystemRequirements-RecommendedHardware."
}

variable "bucket_name" {
  type        = string
  description = "AWS S3 Bucket name"
}

variable "db_name" {
  type        = string
  description = "MySQL database name"
  default     = "artdb"
}

variable "db_user" {
  type        = string
  description = "Database user name"
  default     = "artifactory"
}

variable "db_instance_class" {
  type        = string
  description = "The database instance type"
  default     = "db.t2.small"
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "db_allocated_storage" {
  type        = string
  description = "The size of the database (Gb)"
  default     = "5"
}

variable "master_key" {
  description = "Master key for Artifactory cluster. Generate master.key using command '$openssl rand -hex 16'"
  default     = "35767fa0164bac66b6cccb8880babefb"
  sensitive   = true
}

variable "artifactory_server_name" {
  description = "Provide artifactory server name to be used in Nginx. e.g artifactory for artifactory.jfrog.team"
  default     = "artifactory"
}

variable "elb_name" {
  type        = string
  description = "The name of the Load balancer"
  default     = "artifactoryelb"
}

variable "access_cidr" {
  type = list(any)
}

variable "ssh_access" {
  type = list(any)
}

variable "artifactory_sg_name" {
  type        = string
  default     = "artifactory_sg"
  description = "(optional) describe your variable"
}

variable "sse_algorithm" {
  description = "The type of encryption algorithm to use"
  type        = string
  default     = "aws:kms"
}

variable "subnet_ids" {
  description = "A list of Subnet ids"
  type        = list(any)
}

variable "vpc_id" {
  description = "The VPC id"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC"
  type        = list(any)
}

variable "profile_name" {
  type        = string
  default     = "artifactory"
  description = "Instance profile name"
}

variable "ssl_certificate_id" {
  type        = string
  description = "The ID of the SSL certificate from ACM"
}

variable "zone_id" {
  type        = string
  description = "The Route53 zone for the record"
}

variable "record" {
  type        = string
  description = "Value for Route53 entry"
}


variable "autoscaling_group_name" {
  type        = string
  description = "artifactory autoscaling group"
  default     = "artifactory autoscaling group"
}

variable "rds" {
  type = map(any)
  default = {
    storage_type        = "gp3"
    engine              = "mysql"
    engine_version      = "5.5"
    multi_az            = "false"
    skip_final_snapshot = "true"
  }
  description = "Settings for the DB instance"
}

variable "monitoring_interval" {
  type        = string
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance"
  default     = 30

  validation {
    condition     = can(regex("0|1|5|10|15|30|60", var.monitoring_interval))
    error_message = "Valid Values: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "monitoring_role_arn" {
  type    = string
  default = ""
}
