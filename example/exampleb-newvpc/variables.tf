variable "vpc_cidr" {
  type    = list(any)
  default = ["10.0.0.0/16"]
}

variable "bucket_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "m4.xlarge"
}

variable "ssh_access" {
  type = list(any)
}

variable "access_cidr" {
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
