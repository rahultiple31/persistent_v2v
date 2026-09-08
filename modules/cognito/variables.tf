variable "app_name" {
  description = "Application name used for Cognito resource names."
  type        = string
}

variable "frontend_client_name" {
  description = "Cognito User Pool app client name for the webapp."
  type        = string
}

variable "cognito_domain_prefix" {
  description = "Globally unique Cognito hosted UI domain prefix. Must not contain aws, amazon, or cognito."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$", var.cognito_domain_prefix)) && length(regexall("(aws|amazon|cognito)", var.cognito_domain_prefix)) == 0
    error_message = "cognito_domain_prefix must be 1-63 lowercase letters, numbers, or hyphens, start/end alphanumeric, and not contain aws, amazon, or cognito."
  }
}

variable "callback_urls" {
  description = "Cognito callback URLs."
  type        = list(string)
}

variable "logout_urls" {
  description = "Cognito logout URLs."
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags applied to supported resources."
  type        = map(string)
  default     = {}
}
