output "address" {
  value       = aws_lb.web.dns_name
  description = "URL of the Artifactory"
}
