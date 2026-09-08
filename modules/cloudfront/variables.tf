variable "name_prefix" {
  description = "Name prefix for CloudFront resources."
  type        = string
}

variable "app_name" {
  description = "Application name used in CloudFront comments."
  type        = string
}

variable "webapp_root_prefix" {
  description = "S3 object prefix that CloudFront serves as the web application root."
  type        = string
}

variable "webapp_bucket_regional_domain_name" {
  description = "Regional domain name for the webapp bucket."
  type        = string
}

variable "webapp_log_bucket_domain_name" {
  description = "Domain name for the CloudFront log bucket."
  type        = string
}

variable "polly_region" {
  description = "AWS Region used by Amazon Polly."
  type        = string
}

variable "polly_proxy_enabled" {
  description = "Whether CloudFront should proxy browser requests to Amazon Polly."
  type        = bool
}

variable "translate_region" {
  description = "AWS Region used by Amazon Translate."
  type        = string
}

variable "translate_proxy_enabled" {
  description = "Whether CloudFront should proxy browser requests to Amazon Translate."
  type        = bool
}

variable "common_tags" {
  description = "Common tags applied to supported resources."
  type        = map(string)
  default     = {}
}
