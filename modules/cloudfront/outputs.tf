output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for the webapp."
  value       = aws_cloudfront_distribution.webapp.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN for the webapp."
  value       = aws_cloudfront_distribution.webapp.arn
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.webapp.domain_name
}

output "webapp_url" {
  description = "Public HTTPS URL for the V2V webapp."
  value       = "https://${aws_cloudfront_distribution.webapp.domain_name}"
}
