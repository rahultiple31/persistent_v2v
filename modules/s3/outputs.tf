output "webapp_bucket_name" {
  description = "S3 bucket that stores the webapp assets."
  value       = aws_s3_bucket.webapp.bucket
}

output "webapp_bucket_arn" {
  description = "S3 webapp bucket ARN."
  value       = aws_s3_bucket.webapp.arn
}

output "webapp_bucket_regional_domain_name" {
  description = "Regional domain name for the webapp bucket."
  value       = aws_s3_bucket.webapp.bucket_regional_domain_name
}

output "webapp_log_bucket_name" {
  description = "S3 bucket that stores CloudFront access logs."
  value       = aws_s3_bucket.webapp_logs.bucket
}

output "webapp_log_bucket_domain_name" {
  description = "Domain name for the CloudFront log bucket."
  value       = aws_s3_bucket.webapp_logs.bucket_domain_name
}

output "webapp_logs_acl_id" {
  description = "CloudFront log bucket ACL resource ID."
  value       = aws_s3_bucket_acl.webapp_logs.id
}
