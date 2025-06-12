output "primary_record_fqdn" {
    description = "FQDN of the primary Route 53 record"
    value       = aws_route53_record.primary.fqdn
  }