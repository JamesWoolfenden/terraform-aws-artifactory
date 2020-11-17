variable "common_tags" {
  description = "This is to help you add tags to your cloud objects"
  type        = map
}


variable "vpc_cidr" {
  type    = list
  default = ["10.0.0.0/16"]
}