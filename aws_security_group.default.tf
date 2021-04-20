# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = var.artifactory_sg_name
  description = "Used in the terraform"
  vpc_id      = var.vpc_id


  ingress {
    description = "SSH access from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_access
  }

  ingress {
    description = "HTTP access from the VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr
  }

  ingress {
    description = "HTTPS access from the VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr
  }

  ingress {
    description = "HTTPS access from the VPC"
    from_port   = 10001
    to_port     = 10001
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr
  }

  ingress {
    description = "HTTP access from the VPC"
    from_port   = 8081
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr
  }


  ingress {
    cidr_blocks      = var.ssh_access
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }


  egress {
    description = "outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # tfsec:ignore:AWS009
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}
