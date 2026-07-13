output "address" {
  value       = aws_lb.web.dns_name
  description = "URL of the Artifactory"
}

output "load_balancer_arn" {
  value       = aws_lb.web.arn
  description = "ARN of the Artifactory application load balancer"
}

output "load_balancer_zone_id" {
  value       = aws_lb.web.zone_id
  description = "Route53 hosted zone ID of the load balancer, for creating alias records"
}

output "db_instance_endpoint" {
  value       = aws_db_instance.default.endpoint
  description = "Connection endpoint (host:port) of the Artifactory RDS instance"
}

output "db_instance_id" {
  value       = aws_db_instance.default.id
  description = "Identifier of the Artifactory RDS instance"
}

output "db_instance_arn" {
  value       = aws_db_instance.default.arn
  description = "ARN of the Artifactory RDS instance"
}

output "bucket_id" {
  value       = aws_s3_bucket.b.id
  description = "Name of the S3 bucket used for Artifactory binary storage"
}

output "bucket_arn" {
  value       = aws_s3_bucket.b.arn
  description = "ARN of the S3 bucket used for Artifactory binary storage"
}

output "security_group_id" {
  value       = aws_security_group.default.id
  description = "ID of the security group attached to the Artifactory instances"
}

output "load_balancer_security_group_id" {
  value       = aws_security_group.elb.id
  description = "ID of the security group attached to the load balancer"
}

output "iam_role_arn" {
  value       = aws_iam_role.art.arn
  description = "ARN of the IAM role attached to the Artifactory instances"
}

output "iam_role_name" {
  value       = aws_iam_role.art.name
  description = "Name of the IAM role attached to the Artifactory instances"
}

output "autoscaling_group_name" {
  value       = aws_autoscaling_group.art.name
  description = "Name of the Artifactory autoscaling group"
}

output "autoscaling_group_arn" {
  value       = aws_autoscaling_group.art.arn
  description = "ARN of the Artifactory autoscaling group"
}

output "launch_template_id" {
  value       = aws_launch_template.master.id
  description = "ID of the Artifactory launch template"
}

output "waf_web_acl_arn" {
  value       = aws_wafv2_web_acl.web.arn
  description = "ARN of the WAFv2 web ACL protecting the load balancer"
}

# holden:ignore:HLD_TF_050: this is the key pair's name (e.g. "jfrog"), not key material
output "key_pair_name" {
  value       = aws_key_pair.ssm_key.key_name
  description = "Name of the generated EC2 key pair"
}
