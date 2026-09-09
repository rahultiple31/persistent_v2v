variable "project_name" {
  description = "Project prefix used for names and tags."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "aws_region" {
  description = "AWS region for this module instance."
  type        = string
}

variable "region_code" {
  description = "Business region code, for example us, europe, or apac."
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to resources."
  type        = map(string)
}

variable "contact_center_alias" {
  description = "Base alias for Amazon Connect instances."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9_-]*$", var.contact_center_alias))
    error_message = "contact_center_alias must start with a letter or number and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "connect_name_suffix" {
  description = "Suffix used in the Amazon Connect instance alias."
  type        = string
  default     = "connect"

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9_-]*$", var.connect_name_suffix))
    error_message = "connect_name_suffix must start with a letter or number and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "admin_user_enabled" {
  description = "Whether to create an initial Amazon Connect administrator user."
  type        = bool
  default     = false

  validation {
    condition = !var.admin_user_enabled || alltrue([
      var.admin_user_first_name != null,
      var.admin_user_last_name != null,
      var.admin_user_username != null,
      var.admin_user_password != null,
      var.admin_user_email != null
    ])
    error_message = "When admin_user_enabled is true, all admin user fields must be provided."
  }
}

variable "admin_user_first_name" {
  description = "First name for the Amazon Connect administrator user."
  type        = string
  default     = null
}

variable "admin_user_last_name" {
  description = "Last name for the Amazon Connect administrator user."
  type        = string
  default     = null
}

variable "admin_user_username" {
  description = "Username for the Amazon Connect administrator user."
  type        = string
  default     = null
}

variable "admin_user_password" {
  description = "Password for the Amazon Connect administrator user. Set this from a secret variable."
  type        = string
  default     = null
  sensitive   = true
}

variable "admin_user_email" {
  description = "Email address for the Amazon Connect administrator user."
  type        = string
  default     = null
}
