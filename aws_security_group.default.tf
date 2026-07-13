# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = var.artifactory_sg_name
  description = "Used in the terraform"
  vpc_id      = var.network.vpc_id


  ingress {
    description = "SSH access from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.network.ssh_access
  }

  ingress {
    description = "HTTP access from the VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.network.vpc_cidr
  }

  ingress {
    description = "HTTPS access from the VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.network.vpc_cidr
  }

  ingress {
    description = "HTTPS access from the VPC"
    from_port   = 10001
    to_port     = 10001
    protocol    = "tcp"
    cidr_blocks = var.network.vpc_cidr
  }

  ingress {
    description = "HTTP access from the VPC"
    from_port   = 8081
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = var.network.vpc_cidr
  }


  ingress {
    description = "Allow all traffic between members of this security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }


  # The boot script (userdata.sh.template) only ever calls out over HTTPS
  # (yum/amazon-linux-extras repos, wget/curl downloads) plus DNS to resolve
  # those hosts - not all ports.
  egress {
    description = "HTTPS package downloads and updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS resolution within the VPC"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = var.network.vpc_cidr
  }

  egress {
    description = "DNS resolution within the VPC"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = var.network.vpc_cidr
  }
}
