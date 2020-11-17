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
