variable "common_tags" {
  description = "This is to help you add tags to your cloud objects"
  type        = map
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = list
}

variable "subnet_ids" {
  type = list
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
