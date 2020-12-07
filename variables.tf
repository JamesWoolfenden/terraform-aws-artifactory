
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
  default     = "password"
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
  description = "Thge name of the Load balancer"
  default     = "artifactoryelb"
}

variable "common_tags" {
  type        = map(any)
  description = "Implements the common tags scheme"
  default = {
  "createdby" = "Terraform" }
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
  type    = string
  default = "artifactory"
}

variable "ssl_certificate_id" {
  type        = string
  description = "The ID of the SSL certificate from ACM"
}

variable "zone_id" {
  type = string
}

variable "record" {
  type = string
}
