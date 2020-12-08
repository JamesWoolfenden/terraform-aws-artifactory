variable "common_tags" {
  description = "This is to help you add tags to your cloud objects"
  type        = map(any)
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = list(any)
}

variable "subnet_ids" {
  type = list(any)
}

variable "ssl_certificate_id" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "record" {
  type = string
}

variable "instance_type" {
  type        = string
  description = "The size/type of your instance"
  default     = "t3.micro"
}
