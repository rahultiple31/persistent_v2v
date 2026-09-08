variable "aws_region" {
  description = "AWS region for the V2V solution."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "uat"
}

variable "project_name" {
  description = "Project prefix used for names and tags."
  type        = string
  default     = "abbvie"
}

variable "app_name" {
  description = "Application name used for AWS resource names."
  type        = string
  default     = "AmazonConnectV2V"
}

variable "frontend_client_name" {
  description = "Cognito User Pool app client name for the webapp."
  type        = string
  default     = "AmazonConnectV2VFrontend"
}

variable "ssm_hierarchy" {
  description = "SSM Parameter Store hierarchy used by the V2V solution."
  type        = string
  default     = "/AmazonConnectV2V/"
}

variable "webapp_root_prefix" {
  description = "S3 object prefix that CloudFront serves as the web application root."
  type        = string
  default     = "WebAppRoot/"
}

variable "webapp_staging_prefix" {
  description = "S3 object prefix reserved for staging artifacts."
  type        = string
  default     = "WebAppStaging/"
}

variable "cognito_domain_prefix" {
  description = "Globally unique Cognito hosted UI domain prefix. Must not contain aws, amazon, or cognito."
  type        = string
}

variable "cognito_callback_urls" {
  description = "Additional Cognito callback URLs, for example local development URLs."
  type        = list(string)
  default     = ["https://localhost:5173"]
}

variable "cognito_logout_urls" {
  description = "Additional Cognito logout URLs, for example local development URLs."
  type        = list(string)
  default     = ["https://localhost:5173"]
}

variable "connect_instance_url" {
  description = "Existing Amazon Connect instance URL used by the embedded CCP."
  type        = string
}

variable "connect_instance_region" {
  description = "AWS Region of the existing Amazon Connect instance."
  type        = string
}

variable "transcribe_region" {
  description = "AWS Region used by Amazon Transcribe streaming."
  type        = string
  default     = "us-east-1"
}

variable "translate_region" {
  description = "AWS Region used by Amazon Translate."
  type        = string
  default     = "us-east-1"
}

variable "translate_proxy_enabled" {
  description = "Whether CloudFront should proxy browser requests to Amazon Translate."
  type        = bool
  default     = true
}

variable "polly_region" {
  description = "AWS Region used by Amazon Polly."
  type        = string
  default     = "us-east-1"
}

variable "polly_proxy_enabled" {
  description = "Whether CloudFront should proxy browser requests to Amazon Polly."
  type        = bool
  default     = true
}

variable "deploy_webapp_assets" {
  description = "Whether Terraform uploads files from webapp_dist_path to the hosting bucket."
  type        = bool
  default     = false
}

variable "webapp_dist_path" {
  description = "Path to the built Vite webapp dist directory."
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}
