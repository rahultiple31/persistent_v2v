variable "app_name" {
  description = "Application name used for bucket names."
  type        = string
}

variable "webapp_root_prefix" {
  description = "S3 object prefix that CloudFront serves as the web application root."
  type        = string
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

variable "frontend_config" {
  description = "Configuration object written to frontend-config.js."
  type        = map(string)
}

variable "common_tags" {
  description = "Common tags applied to supported resources."
  type        = map(string)
  default     = {}
}
