output "address" {
  value       = aws_elb.web.dns_name
  description = "URL of the Artifactory "
}


output "autoscaling_group_secondary" {
  value = aws_cloudformation_stack.autoscaling_group_secondary
}

output "autoscaling_group" {
  value = aws_cloudformation_stack.autoscaling_group
}
